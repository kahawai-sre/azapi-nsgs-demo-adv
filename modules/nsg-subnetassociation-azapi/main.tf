

resource "azapi_update_resource" "this" {
  type        = "Microsoft.Network/virtualNetworks/subnets@2022-07-01"
  resource_id = var.subnet_id
  body = jsonencode({
    properties = {
      networkSecurityGroup = {
        id = var.nsg_id
      }
    }
  })
}

