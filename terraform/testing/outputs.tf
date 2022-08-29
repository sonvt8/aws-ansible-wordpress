output "ec2-za-ids" {
  value = values(module.ec2_za)[*].id
}

output "ec2-za-ips" {
  value = values(module.ec2_za)[*].public_ip
}

output "ec2-zb-ids" {
  value = values(module.ec2_zb)[*].id
}

output "ec2-zb-ips" {
  value = values(module.ec2_zb)[*].public_ip
}

output "alb_dns_name" {
  description = "Dns name of ALB"
  value       = module.alb.lb_dns_name
}

output "rds_endpoint" {
  description = "Endpoint of RDS instance"
  value       = module.rds_db.db_instance_endpoint
}

output "db_name" {
  value = module.rds_db.db_instance_name
}

output "db_username" {
  value     = module.rds_db.db_instance_username
  sensitive = true
}

output "db_password" {
  value     = module.rds_db.db_instance_password
  sensitive = true
}