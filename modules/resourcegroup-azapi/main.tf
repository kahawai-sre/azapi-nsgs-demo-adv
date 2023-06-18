
resource "azapi_resource" "RESOURCEGROUP" {
  type                   = "Microsoft.Resources/resourceGroups@2022-09-01"
  name                   = var.name
  location               = var.location
  parent_id              = var.parent_id
  tags                   = var.tags
  response_export_values = ["*"]
}
