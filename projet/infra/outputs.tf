output "vpc_id" {
  value = module.network.vpc_id
}
output "instance_id" {
  value = module.compute.instance_id
}
output "connexion_ssm" {
  value = "aws ssm start-session --target ${module.compute.instance_id} --region ${var.region}"
}
