#!/bin/bash
# cert generator script
# This script takes json input and returns JSON output. Be careful with letting this live in our S3 statefile, as there are credentials. Ideally it should send to vault or similar.
# I will put up examples of this working from an external terraform plan

function error_exit() {
  echo "$1" 1>&2
  exit 1
}

function parse_input() {
 eval "$(jq -r '@sh "export CERT_NAME=\(.cert_name) SAN_DOMAINS=\(.san_names)"')"
 if [[ -z "${CERT_NAME}" ]]; then error_exit "need cert name"; fi
 if [[ -z "${SAN_DOMAINS}" ]]; then error_exit "need san domains"; fi
}

function request_cert() {
    cat current-run.out >> certbot-runs.log
    echo "Run Start $(date)" > current-run.out
    docker run -i --rm --name certbot --dns 8.8.4.4 -v "/etc/letsencrypt:/etc/letsencrypt" -v "/var/lib/letsencrypt:/var/lib/letsencrypt"  -v "/root/.aws/credentials:/root/.aws/credentials" certbot/dns-route53 certonly --expand --force-renewal --cert-name ${CERT_NAME} -n --agree-tos --email devops@flexdrive.com --dns-route53 -d ${SAN_DOMAINS} >> current-run.out
}

function check_status() {
    STAT="$(cat current-run.out | grep -c Congratulations)"
    confirm_done
}

function confirm_done() {
    if [ $STAT -gt 0 ]; then
        produce_output
    else
        sleep 5
        check_status
    fi
}

function format_key() {
    filename=$1
    somefile="$(readlink ${filename})"
    ruby_out="$(/usr/bin/env ruby -e 'p ARGF.read' /etc/letsencrypt/${somefile:6})"
    echo ${ruby_out}
}

function produce_output() {
    cat current-run.out | grep pem > filenames.txt
    PRIVATE_KEY="$(cat filenames.txt | grep priv | xargs| tr -d '\r')"
    FULLCHAIN="$(cat filenames.txt | grep full | xargs | tr -d '\r')"
    # Generate outputs
    KEYFILE=$(format_key ${PRIVATE_KEY})
    CERTFILE=$(format_key ${FULLCHAIN})
    # Send to consul
    # https://www.consul.io/docs/connect/ca/consul.html
    jq -n \
        --arg timestamp "$(date -u)" \
        --arg cert_name "$CERT_NAME" \
        --arg cert_contents "$CERTFILE" \
        --arg cert_key "$KEYFILE" \
        '{"timestamp":$timestamp,"cert_name":$cert_name,"cert_contents":$cert_contents,"cert_key":$cert_key}'
}

parse_input
request_cert
check_status

