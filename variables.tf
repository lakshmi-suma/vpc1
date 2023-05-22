variable "resource_group_id" {
    type = string
  
}
variable "resource_group" {
    type = string
  
}
variable "id" {
  type = list()
  default = local.ids
  
}