webapp_environment = {
  "prodcution" = {
    service-plan = {
      primary-plan-windows = {
        sku     = "F1"
        os_type = "Windows"
      }
      primary-plan-linux = {
        sku     = "F1"
        os_type = "Linux"
      }
    }
    appservice = {
      webappterrafom098ls7 = "primary-plan-windows"
    }
  }
}