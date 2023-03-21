variable "tupla_rgname_lc" {
  type = map(any)
}

variable "prefix" {
  type = string
}

variable "project" {
  type = string
}


//Variables recursos
//SQLServer
variable "sqlserver_name" {
  type = string
}
variable "admin_username" {
  type = string
}
variable "db_name" {
  type = string
}
variable "admin_password" {
  type = string

}

//LogAnalytics
variable "loganalytics_name" {
  type = string

}


