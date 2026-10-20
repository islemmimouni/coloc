variable "project" {
  type    = string
  default = "coloc"
}
variable "environment" {
  type        = string
  description = "dev ou prod"
}
variable "region" {
  type = string
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "az_count" {
  type        = number
  default     = 2
  description = "Nombre de zones de disponibilité (multi-AZ = 2 minimum)"
}
variable "enable_nat" {
  type        = bool
  default     = true
  description = "Accès sortant des sous-réseaux privés via NAT Gateway (voir docs/adr/0001)"
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "instance_profile_name" {
  type        = string
  default     = null
  description = "Profil d'instance existant (ex. LabInstanceProfile sur un compte pédagogique)"
}
variable "budget_limit_usd" {
  type = number
}
variable "budget_emails" {
  type = list(string)
}
