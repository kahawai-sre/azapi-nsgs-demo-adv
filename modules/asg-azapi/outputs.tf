output "asg_id" {
  value = jsondecode(azapi_resource.ASG.output).id
}

output "asg_name" {
  value = jsondecode(azapi_resource.ASG.output).name
}

output "asg_location" {
  value = jsondecode(azapi_resource.ASG.output).location
}

