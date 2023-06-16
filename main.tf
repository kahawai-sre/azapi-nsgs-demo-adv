

#// 1. Deploy resource groups as per "resourcegroups_config_map" defined in locals.tf
module "resourcegroup-azapi" {
  for_each = local.resourcegroups_config_map
  source   = "./modules/resourcegroup-azapi/"
  name     = each.value.name
  location = each.value.location
  #parent_id = local.sub_config_map[each.value.sub_name].id
  parent_id = each.value.parent_id
  tags      = each.value.tags
}

#// 2. Deploy ASGs as per "asgs_config_map" defined in locals.tf
module "asg-azapi" {
  for_each = local.asgs_config_map
  source   = "./modules/asg-azapi/"
  name     = each.value.name
  location = each.value.location
  # Prefer hard coded "parent_id" if it is defined in the config (allows for referencing existing 'external' resources).
  # Otherwise, dynamically match to a resource group deployed as part of this TF manifest
  parent_id = each.value.parent_id == null ? module.resourcegroup-azapi[each.value.rg_name].resourcegroup_id : each.value.parent_id
  tags      = each.value.tags
}

#// 3. Deploy NSGs and associated securityRules as per "nsgs_config_map" defined in locals.tf
module "nsg-azapi" {
  for_each = local.nsgs_config_map
  source   = "./modules/nsg-azapi/"
  name     = each.value.name
  location = each.value.location
  # Prefer hard coded "parent_id" if it is defined in the config (allows for referencing existing 'external' resources).
  # Otherwise, dynamically match to a resource group deployed as part of this TF manifest
  parent_id       = each.value.parent_id == null ? module.resourcegroup-azapi[each.value.rg_name].resourcegroup_id : each.value.parent_id
  flushConnection = each.value.flushConnection
  securityRules = each.value.securityRules == null ? null : [for rule in each.value.securityRules :
    {
      name = rule.name
      properties = {
        access                               = rule.properties.access
        direction                            = rule.properties.direction
        priority                             = rule.properties.priority
        protocol                             = rule.properties.protocol
        description                          = try(rule.properties.description, null)
        sourceAddressPrefix                  = try(rule.properties.sourceAddressPrefix, null)
        sourceAddressPrefixes                = try([for SAddrPrefix in rule.properties.sourceAddressPrefixes : SAddrPrefix], null)
        sourceApplicationSecurityGroups      = try([for SASGs in rule.properties.sourceApplicationSecurityGroups : { id = module.asg-azapi[SASGs.name].asg_id }], null) # <<=== TODO: support optional hard coded ASG resource IDs
        sourcePortRange                      = try(rule.properties.sourcePortRange, null)
        sourcePortRanges                     = try([for SPortRange in rule.properties.sourcePortRanges : SPortRange], null)
        destinationAddressPrefix             = try(rule.properties.destinationAddressPrefix, null)
        destinationAddressPrefixes           = try([for DAddrPrefix in rule.properties.destinationAddressPrefixes : DAddrPrefix], null)
        destinationApplicationSecurityGroups = try([for DASGs in rule.properties.destinationApplicationSecurityGroups : { id = module.asg-azapi[DASGs.name].asg_id }], null) # <<=== TODO: support optional hard coded ASG resource IDs
        destinationPortRange                 = try(rule.properties.destinationPortRange, null)
        destinationPortRanges                = try([for DPortRange in rule.properties.destinationPortRanges : DPortRange], null)
      }
    }
  ]
  tags       = each.value.tags
  depends_on = [module.resourcegroup-azapi, module.asg-azapi, data.azurerm_subscriptions.available]
}

#// 4. Deploy NSG=>Subnet associations as per "nsg_subnet_associations_map" defined in locals.tf
#// NOTE: using azapi_update_resource here. This has limitation as described here: https://github.com/Azure/terraform-provider-azapi/issues/204
module "nsg-subnetassociation-azapi" {
  for_each = local.nsg_subnet_associations_map
  source   = "./modules/nsg-subnetassociation-azapi/"
  #// NOTE: line below is a WIP. Need to determine how to remove the properties.networkSecurityGroup property from the target subnet configuration using azapi_update_resource, or otherwise
  #// as per limitation described here https://github.com/Azure/terraform-provider-azapi/issues/204
  nsg_id     = each.value.associated_state == true ? module.nsg-azapi[each.value.nsg_name].nsg_id : "" #// <<<=== check value of the "associated_state" flag. If associated_state = true, do the assignment, else, clear the assignment e.g. remove networkSecurityGroup property  (for Day2 ops where want to clear subnet => NSG association)
  subnet_id  = each.value.subnet_id
  depends_on = [module.nsg-azapi]
}

#// TO DO:
#// ======
#// 5. Deploy NSG=>vNIC associations as per " nsg_vnic_associations_flatten" defined in locals.tf
