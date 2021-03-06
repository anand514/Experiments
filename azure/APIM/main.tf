data "azurerm_client_config" "current" {}

locals {
  full_prefix = "${var.resource_prefix}-${var.environment}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.full_prefix}-rg"
  location = var.location
}

resource "azurerm_api_management" "apim" {
  name                = "${local.full_prefix}-apim"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email

  sku_name = "Developer_1"

  identity {
    type = "SystemAssigned"
  }

  protocols {
    enable_http2 = true
  }

  security {
    enable_backend_ssl30  = false
    enable_frontend_ssl30 = false
  }

  # While the benefits of forcing traffic over the Azure backbone is nice,
  # and sometimes necessary, it can only be done at the Premium APIM tier.
  # As such, one really has to understand if their applications need 
  # such benefits, as the Premium APIM tier is orders of magnitude more
  # expensive than lower tiers.
  # Changing this will destroy the entire APIM instance. Be very careful.
  # virtual_network_type = "External"
  # virtual_network_configuration {
  #   subnet_id = azurerm_subnet.sub_apim.id
  # }
  # Changing this will destroy the entire APIM instance. Be very careful.

  policy {
    xml_content = <<XML
    <policies>
      <inbound />
      <backend />
      <outbound />
      <on-error />
    </policies>
XML

  }
}