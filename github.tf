# terraform {
#   required_providers {
#     github = {
#       source  = "integrations/github"
#       version = "~> 6.0"
#     }
#   }
# }

# # GitHub token is injected via TF_VAR_github_token (set as GitHub Actions Secret: GITHUB_TOKEN_TF)
# variable "github_token" {
#   description = "GitHub Personal Access Token"
#   type        = string
#   sensitive   = true
# }

# # Configure the GitHub Provider
# provider "github" {
#   token = var.github_token
# }

# resource "github_repository" "example" {
#   name        = "example"
#   description = "My awesome codebase"

#   visibility = "public"
# }