terraform {
  required_version = ">= 1.5.0"
  backend "s3" {
    bucket = "company-platform-tfstate"
    key    = "workloads/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  declaration_files = fileset("${path.module}/declarations", "*.json")
  team_declarations = [
    for f in local.declaration_files : jsondecode(file("${path.module}/declarations/${f}"))
  ]
}

module "team_workloads" {
  for_each = { for d in local.team_declarations : "${d.team_name}-${d.environment}" => d }

  source = "./modules/team-workload-factory"

  team_name   = each.value.team_name
  environment = each.value.environment
  buckets     = each.value.buckets
}
