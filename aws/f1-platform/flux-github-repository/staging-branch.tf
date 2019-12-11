# Protect the staging branch of the flux cluster repository. 
### We can require that the "ci/travis" context to be passing and only allow the engineers team merge
### to the branch.
resource "github_branch_protection" "stagingci" {
  repository     = "${github_repository.flux_repo.name}"
  branch         = "staging"
  enforce_admins = true

#   required_status_checks {
#     strict   = false
#     contexts = ["ci/travis"]
#   }

  required_pull_request_reviews {
    dismiss_stale_reviews = true
    dismissal_users       = ["flexdrive-user"]
    dismissal_teams       = ["${github_team.stagingci.slug}", "${github_team.second.slug}"]
  }

  restrictions {
    users = ["flexdrive-user"]
    teams = ["${github_team.stagingci.slug}"]
  }
}

resource "github_team" "stagingci" {
  name = "Flux staging"
}

resource "github_team_repository" "stagingci" {
  team_id    = "${github_team.stagingci.id}"
  repository = "${github_repository.flux_repo.name}"
  permission = "pull"
}

# resource "github_repository" "flux_repo" {
#   name = "${var.cluster_name_prefix}-${element(split(".", var.zone_name), 0)}-${var.stage}-cluster"
# }
