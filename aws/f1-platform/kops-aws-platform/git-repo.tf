
# Add a repository to the team
resource "github_team" "flux_k8s_team" {
  name        = "FluxReaders"
  description = "Github team for flux on new cluster"
}

resource "github_repository" "flux_repo" {
  name = "${var.cluster_name_prefix}-${element(split(".", var.zone_name), 0)}-${var.stage}-cluster"
}
 # skylab-f1-santander-shft-cluster
 # We should really standardize our namespace/stage/etc conventions

resource "github_team_repository" "engineering_pull" {
  team_id    = "${github_team.flux_k8s_team.id}"
  repository = "${github_repository.flux_repo.name}"
  permission = "pull"
}

# https://github.com/orgs/flexdrive/teams/platform-engineering  is tega and the power users / code reviewers / etc


# I removed this for now until we finalize ssh key strategy
# Add a deploy key
# resource "github_repository_deploy_key" "git_deploy_key" {
#   title      = "Flux Deploy Key"
#   repository = "${github_repository.flux_repo.name}"
#   key        = "${file("some-key.pub")}"
#   read_only  = "false"
# }

# Add a repository to the team
# resource "github_team" "prodci" {
#   name        = "prod-${var.stage}-access"
#   description = "Github team for flux on new cluster"
# }

# Protect the prod branch of the foo repository. Additionally, require that
# the "ci/travis" context to be passing and only allow the engineers team merge
# # to the branch.

# resource "github_branch_protection" "prodci" {
#   repository     = "${github_repository.flux_repo.name}"
#   branch         = "prod"
#   enforce_admins = true

#   required_status_checks {
#     strict   = false
#     contexts = ["ci/travis"]
#   }

#   required_pull_request_reviews {
#     dismiss_stale_reviews = true
#     dismissal_users       = ["foo-user"]
#     dismissal_teams       = ["${github_team.flux_k8s_team.slug}", "${github_team.prodci.slug}"]
#   }

#   restrictions {
#     users = ["foo-user"]
#     teams = ["${github_team.flux_k8s_team.slug}"]
#   }
# }

# resource "github_team" "stagingci" {
#   name = "staging-${var.stage}-access"
# }


# resource "github_branch_protection" "stagingci" {
#   repository     = "${github_repository.flux_repo.name}"
#   branch         = "staging"
#   enforce_admins = true

#   required_status_checks {
#     strict   = false
#     contexts = ["ci/travis"]
#   }

#   required_pull_request_reviews {
#     dismiss_stale_reviews = true
#     dismissal_users       = ["foo-user"]
#     dismissal_teams       = ["${github_team.flux_k8s_team.slug}", "${github_team.stagingci.slug}"]
#   }

#   restrictions {
#     users = ["foo-user"]
#     teams = ["${github_team.flux_k8s_team.slug}"]
#   }
# }




# resource "github_team_repository" "prodci" {
#   team_id    = "${github_team.prodci.id}"
#   repository = "${github_repository.flux_repo.name}"
#   permission = "pull"
# }