variable "project"     { type = string }
variable "aws_region"  { type = string }

# GitHub org/repo used by your CI workflow
variable "github_org"  { type = string }
variable "github_repo" { type = string }

# Optional: restrict OIDC to branch or env; keep simple for speed
variable "github_ref_condition" {
  type        = string
  description = "Optional condition on token 'ref' (e.g., 'refs/heads/main'). Leave empty to allow all refs."
  default     = ""
}
