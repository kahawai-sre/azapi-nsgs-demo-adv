
resource "azapi_resource" "this" {
  type                   = "Microsoft.Network/applicationSecurityGroups@2022-07-01"
  name                   = var.name
  location               = var.location
  parent_id              = var.parent_id
  tags                   = var.tags
  response_export_values = ["*"]
}
