# Add a repository to the team
resource "github_team" "flux_k8s_team" {
  name        = "FluxReaders"
  description = "Github team for flux on new cluster"
}

resource "github_repository" "test_repo" {
  name = "test-gitrepo-create"
}

resource "github_team_repository" "engineering_pull" {
  team_id    = "${github_team.flux_k8s_team.id}"
  repository = "${github_repository.test_repo.name}"
  permission = "pull"
}

# https://github.com/orgs/flexdrive/teams/platform-engineering  is tega and the power users / code reviewers / etc

# Configure the GitHub Provider
provider "github" {
  token        = "${var.github_token}"
  organization = "${var.github_organization}"
}

variable "github_token" {
  description = "What is your github Web API token? for pull over https"
}
variable "github_organization" {
  default = "flexdrive"
  description = "what is the name of the github organization that houses your ci-cd repositories?"
}
# Add a deploy key
resource "github_repository_deploy_key" "git_deploy_key" {
  title      = "Flux Deploy Key"
  repository = "${github_repository.test_repo.name}"
  key        = "${file("quick-make.pub")}"
  read_only  = "false"
}
