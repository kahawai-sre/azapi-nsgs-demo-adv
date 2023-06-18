
output "nsg_id" {
  value = jsondecode(azapi_resource.NSG.output).id
}

output "nsg_name" {
  value = jsondecode(azapi_resource.NSG.output).name
}

output "nsg_location" {
  value = jsondecode(azapi_resource.NSG.output).location
}
