output "asg_id" {
  value = jsondecode(azapi_resource.this.output).id
}

output "asg_name" {
  value = jsondecode(azapi_resource.this.output).name
}

output "asg_location" {
  value = jsondecode(azapi_resource.this.output).location
}

