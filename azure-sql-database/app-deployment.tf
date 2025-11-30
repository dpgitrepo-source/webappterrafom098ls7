
resource "azurerm_resource_group" "primary-app-grp" {
  name     = "primary-rg"
  location = "Canada Central"
}

resource "azurerm_service_plan" "primar-app-plan" {
  for_each = var.webapp_environment.prodcution.service-plan
  name                = "${each.key}"
  resource_group_name = azurerm_resource_group.primary-app-grp.name
  location            = azurerm_resource_group.primary-app-grp.location
  os_type             = each.value.os_type
  sku_name            = each.value.sku
}

resource "azurerm_windows_web_app" "primary-webapp" {
  for_each = var.webapp_environment.prodcution.appservice
  name                = "${each.key}"
  resource_group_name = azurerm_resource_group.primary-app-grp.name
  location            = azurerm_resource_group.primary-app-grp.location
  service_plan_id     = azurerm_service_plan.primar-app-plan[each.value].id

  site_config {
    always_on = false
    application_stack {
      current_stack = "dotnet"
      dotnet_version = "v8.0"
    }
  }
  connection_string {
    name = "AZURE_SQL_CONNECTIONSTRING"
    type = "SQLAzure"
    value = "Server=tcp:${azurerm_mssql_server.web-sqldbserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.web-sqldb.name};Persist Security Info=False;User ID=${azurerm_mssql_server.web-sqldbserver.administrator_login};Password=${azurerm_mssql_server.web-sqldbserver.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

  }
}

resource "azurerm_mssql_firewall_rule" "allow-acces-services" {
  name             = "FirewallRule1"
  server_id        = azurerm_mssql_server.web-sqldbserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}


resource "azurerm_app_service_source_control" "app-sourcectrl" {
  for_each = var.webapp_environment.prodcution.appservice
  app_id   = azurerm_windows_web_app.primary-webapp[each.key].id
  repo_url = "https://github.com/dpgitrepo-source/webappterrafom098ls7.git"
  branch   = "main"
  use_manual_integration = true

   depends_on = [
    azurerm_windows_web_app.primary-webapp
  ]
}