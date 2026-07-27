variable "region" { type = string }
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}
variable "cloudflare_api_token" {
  type     = string
  default  = null
  nullable = true
}
variable "cloudflare_zone_id" {
  type     = string
  default  = null
  nullable = true
}
variable "app_attest_root_sha256" {
  type     = string
  default  = null
  nullable = true
}
variable "production_certificate_arn" {
  type     = string
  default  = null
  nullable = true
}
