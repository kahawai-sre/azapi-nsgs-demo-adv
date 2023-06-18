

resource "azapi_update_resource" "NSG-SUBNET-ASSOCIATION" {
  type        = "Microsoft.Network/virtualNetworks/subnets@2022-07-01"
  resource_id = var.subnet_id
  #// NOTE: the conditional based on 'var.enable_association' below is a workaround for the limitation with azapi_update_resource 
  #// not handling property deletes as per https://github.com/Azure/terraform-provider-azapi/issues/204. 
  #// Toggling "enable_association" to true or false in the "subnet_network_security_group_associations" section of a definition in "./config/nsgs.yaml" 
  #// causes 'azapi_update_resource' to associate or disassociate the NSG from the target subnet so it can be managed in some way for 'Day2" ops.
  body = var.enable_association == true ? jsonencode({
    properties = {
      networkSecurityGroup = {
        id = var.nsg_id
      }
    }
    }) : jsonencode({
    properties = {
      networkSecurityGroup = ""
    }
  })
}

