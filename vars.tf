

#// Path to yaml file defining Resource Groups, to deploy and manage
variable "resourcegroups_yaml_file_path" {
  default = "./config/resourcegroups.yaml"
}

#// Path to yaml file defining ASGs and associated securityRules, to deploy and manage
variable "asgs_yaml_file_path" {
  default = "./config/asgs.yaml"
}

#// Path to yaml file defining NSGs, NSG securityRules, and NSG => subnet associations, to deploy and manage
variable "nsgs_yaml_file_path" {
  default = "./config/nsgs.yaml"
}


