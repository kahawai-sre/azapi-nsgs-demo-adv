
resource "azapi_resource" "NSG" {
  type      = "Microsoft.Network/networkSecurityGroups@2022-07-01"
  name      = var.name
  location  = var.location
  parent_id = var.parent_id #// Fully qualified Id of the parent Resource Group
  tags      = var.tags
  body = jsonencode({
    properties = {
      flushConnection = var.flushConnection
      #// parse security rules and remove properties that are nulls:
      securityRules = var.securityRules == null ? null : [for rule in var.securityRules : { name = rule.name, properties = { for k, v in rule.properties : k => v if v != null } }]
    }
  })
  response_export_values = ["*"]
}





