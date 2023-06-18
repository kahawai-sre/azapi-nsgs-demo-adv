# output "subnet_id" {
#   description = "The id of the subnet newly associated with this NSG"
#   value = [
#     for this in azapi_update_resource.this : this.id
#   ]
# }

output "subnet_id" {
  value = try(jsondecode(azapi_update_resource.NSG-SUBNET-ASSOCIATION.output).id, null)
}


