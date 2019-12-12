## Setting up and enforcing git PR / review

The flux operator is monitoring the `staging` and `prod` branches and enforcing state to the corresponding environment.

### Required Status Checks

`required_status_checks`  supports the following arguments:

-   [`strict`](https://www.terraform.io/docs/providers/github/r/branch_protection.html#strict): (Optional) Require branches to be up to date before merging. Defaults to  `false`.
-   [`contexts`](https://www.terraform.io/docs/providers/github/r/branch_protection.html#contexts): (Optional) The list of status checks to require in order to merge into this branch. No status checks are required by default.

### [»](https://www.terraform.io/docs/providers/github/r/branch_protection.html#required-pull-request-reviews)Required Pull Request Reviews

`required_pull_request_reviews`  supports the following arguments:

-   [`dismiss_stale_reviews`](https://www.terraform.io/docs/providers/github/r/branch_protection.html#dismiss_stale_reviews): (Optional) Dismiss approved reviews automatically when a new commit is pushed. Defaults to  `false`.
-   [`dismissal_users`](https://www.terraform.io/docs/providers/github/r/branch_protection.html#dismissal_users): (Optional) The list of user logins with dismissal access
-   [`dismissal_teams`](https://www.terraform.io/docs/providers/github/r/branch_protection.html#dismissal_teams): (Optional) The list of team slugs with dismissal access. Always use  `slug`  of the team,  **not**  its name. Each team already  **has**  to have access to the repository.
-   [`require_code_owner_reviews`](https://www.terraform.io/docs/providers/github/r/branch_protection.html#require_code_owner_reviews): (Optional) Require an approved review in pull requests including files with a designated code owner. Defaults to  `false`.
-   [`required_approving_review_count`](https://www.terraform.io/docs/providers/github/r/branch_protection.html#required_approving_review_count): (Optional) Require x number of approvals to satisfy branch protection requirements. If this is specified it must be a number between 1-6. This requirement matches Github's API, see the upstream  [documentation](https://developer.github.com/v3/repos/branches/#parameters-1)  for more information.

### [»](https://www.terraform.io/docs/providers/github/r/branch_protection.html#restrictions-1)Restrictions

`restrictions`  supports the following arguments:

-   [`users`](https://www.terraform.io/docs/providers/github/r/branch_protection.html#users): (Optional) The list of user logins with push access.
-   [`teams`](https://www.terraform.io/docs/providers/github/r/branch_protection.html#teams): (Optional) The list of team slugs with push access. Always use  `slug`  of the team,  **not**  its name. Each team already  **has**  to have access to the repository.

`restrictions`  is only available for organization-owned repositories.
