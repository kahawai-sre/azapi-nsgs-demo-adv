output "resourcegroup_id" {
  value = jsondecode(azapi_resource.RESOURCEGROUP.output).id
}

output "resourcegroup_name" {
  value = jsondecode(azapi_resource.RESOURCEGROUP.output).name
}

output "resourcegroup_location" {
  value = jsondecode(azapi_resource.RESOURCEGROUP.output).location
}

