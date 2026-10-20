locals {
  name = "${var.project}-${var.environment}"
}

module "network" {
  source     = "./modules/network"
  name       = local.name
  vpc_cidr   = var.vpc_cidr
  az_count   = var.az_count
  enable_nat = var.enable_nat
}

module "security" {
  source = "./modules/security"
  name   = local.name
  vpc_id = module.network.vpc_id
}

module "compute" {
  source                = "./modules/compute"
  name                  = local.name
  subnet_id             = module.network.private_app_subnet_ids[0]
  security_group_ids    = [module.security.app_sg_id]
  instance_type         = var.instance_type
  instance_profile_name = var.instance_profile_name
  depends_on            = [module.network] # attendre le NAT avant le démarrage de l'instance
}

module "budget" {
  source    = "./modules/budget"
  name      = local.name
  limit_usd = var.budget_limit_usd
  emails    = var.budget_emails
}
