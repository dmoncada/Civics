terraform {
  required_version = ">= 1.8.0"
  backend "s3" {}
  required_providers { aws = { source = "hashicorp/aws", version = "~> 6.0" } }
}

variable "region" {
  type    = string
  default = "us-west-2"
}

provider "aws" { region = var.region }

resource "aws_acm_certificate" "prod" {
  domain_name       = "civics.dmoncada.net"
  validation_method = "DNS"
  lifecycle { create_before_destroy = true }
}

output "certificate_arn" { value = aws_acm_certificate.prod.arn }

output "validation_records" {
  value = [for record in aws_acm_certificate.prod.domain_validation_options : {
    name = record.resource_record_name, type = record.resource_record_type, value = record.resource_record_value
  }]
}
