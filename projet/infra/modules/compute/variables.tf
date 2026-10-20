variable "name" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "security_group_ids" {
  type = list(string)
}
variable "instance_type" {
  type = string
}
variable "instance_profile_name" {
  type    = string
  default = null
}
