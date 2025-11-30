variable "db-name" {
  type    = string
  default = "web-db-2222"
}

variable "location" {
  type    = string
  default = "Canada Central"
}


variable "username" {
  type    = string
  default = "lion"
}

variable "password" {
  type = string

}

variable "webapp_environment" {
  type = map(object({
    service-plan = map(object({
      sku     = string
      os_type = string
    }))
    appservice = map(string)
  }))
}