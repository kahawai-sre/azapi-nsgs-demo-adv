
locals {

  #// Build maps from configuration defined in yaml.
  #// Using yaml files for config vs. tfvars arguably simplifies readability and updates for pull requests by consumers, and abstracts config from code. 
  #// Parsing into maps enables applying any relevant early logic e.g. handling nulls, and generally reduces heavy lifting later in processing chain. 
  #// Also helps encourage maintaining a consistent pattern for defining variable inputs as maps and deploying resources within and across tf deployments. 

  #// 1. Build map of resourcegroups from config defined in yaml file
  resourcegroups_config_raw = yamldecode(file(var.resourcegroups_yaml_file_path))
  resourcegroups_config_flatten = flatten([
    for resourcegroup in local.resourcegroups_config_raw : {
      name      = resourcegroup.name
      location  = resourcegroup.location
      parent_id = resourcegroup.parent_id
      tags      = try(resourcegroup.tags, null)
    }
  ])
  resourcegroups_config_map = { for resourcegroup_config in local.resourcegroups_config_flatten : resourcegroup_config.name => resourcegroup_config }

  #// 2. Build map of ASGs from config defined in yaml file
  asgs_config_raw = yamldecode(file(var.asgs_yaml_file_path))
  asgs_config_flatten = flatten([
    for asg in local.asgs_config_raw : {
      name     = asg.name
      location = asg.location
      #sub_name  = asg.sub_name
      rg_name   = asg.rg_name
      parent_id = try(asg.parent_id, null)
      tags      = try(asg.tags, null)
    }
  ])
  asgs_config_map = { for asg_config in local.asgs_config_flatten : asg_config.name => asg_config }

  #// 3. Build map of NSGs and securityrules from config defined in yaml file
  nsgs_config_raw = yamldecode(file(var.nsgs_yaml_file_path))
  nsgs_config_flatten = flatten([
    for nsg in local.nsgs_config_raw : {
      name                                       = nsg.name
      sub_name                                   = nsg.sub_name
      rg_name                                    = nsg.rg_name
      parent_id                                  = try(nsg.parent_id, null)
      location                                   = nsg.location
      flushConnection                            = nsg.flushConnection
      securityRules                              = try(nsg.securityRules, null) #// <<== NOTE: depending on conflicts with priority, could easily concat with a central list of "default" rules here, to avoid duplication and help with standards
      subnet_network_security_group_associations = try(nsg.subnet_network_security_group_associations, null)
      tags                                       = try(nsg.tags, null)
    }
  ])
  nsgs_config_map = { for nsg_config in local.nsgs_config_flatten : nsg_config.name => nsg_config }

  #// 4. Build map of NSG-subnet associations from config defined in yaml file - not implemented yet
  nsg_subnet_associations_flatten = flatten([for nsg in local.nsgs_config_raw :
    [for nsg_subnet_association in nsg.subnet_network_security_group_associations :
      {
        name             = nsg_subnet_association.name
        nsg_name         = nsg.name
        subnet_name      = try(nsg_subnet_association.subnet_name, null)
        subnet_id        = nsg_subnet_association.subnet_id
        associated_state = nsg_subnet_association.associated_state
      }
    ]
    if nsg.subnet_network_security_group_associations != null
  ])
  nsg_subnet_associations_map = { for nsg_subnet_association in local.nsg_subnet_associations_flatten : nsg_subnet_association.name => nsg_subnet_association }

}
