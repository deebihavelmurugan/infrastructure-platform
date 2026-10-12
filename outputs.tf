output "provisioned_workloads" {
  value = {
    for k, mod in module.team_workloads : k => {
      role_arn     = mod.role_arn
      bucket_names = mod.bucket_names
    }
  }
  description = "Map of all provisioned team infrastructure outputs"
}
