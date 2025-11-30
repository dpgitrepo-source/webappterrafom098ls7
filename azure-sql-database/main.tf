provider "azurerm" {
  features {}
  tenant_id       = "5ce21f9c-7a32-466a-b980-43bac8b3d521"
  subscription_id = "323bf769-4156-483a-bfd9-cad235d08ee8"
}

resource "azurerm_resource_group" "web-db" {
  name     = var.db-name
  location = var.location
}

resource "azurerm_mssql_server" "web-sqldbserver" {
  name                = "${var.db-name}-sqlserver"
  resource_group_name = azurerm_resource_group.web-db.name
  location            = azurerm_resource_group.web-db.location
  version             = "12.0"
  administrator_login = var.username
  administrator_login_password = var.password
}

resource "azurerm_mssql_database" "web-sqldb" {
  name      = "${var.db-name}-database"
  server_id = azurerm_mssql_server.web-sqldbserver.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "S0"
  enclave_type   = "VBS"

  tags = {
    purpose = "webapp-db"
  }

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_mssql_firewall_rule" "web-db-firewall" {
  name             = "${var.db-name}-firewall"
  server_id        = azurerm_mssql_server.web-sqldbserver.id
  start_ip_address = "24.36.151.244"
  end_ip_address   = "24.36.151.244"
}

resource "null_resource" "db-data-insert" {
  triggers = {
    app-version = "6"
  }
  provisioner "local-exec" {
    
    command =  "sqlcmd -S ${azurerm_mssql_server.web-sqldbserver.fully_qualified_domain_name} -d ${azurerm_mssql_database.web-sqldb.name} -U ${var.username} -P ${var.password} -i data.sql"
    
  }
  depends_on = [ azurerm_mssql_database.web-sqldb ]
}
