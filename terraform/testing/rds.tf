module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "${var.env}-rds-security-group"
  description = "Security group for rds instances"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.0.0.0/16"
    }
  ]
}


# https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/4.5.0
module "rds_db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "4.5.0"

  identifier          = "${var.env}-mysql"
  engine              = "mysql"
  engine_version      = "5.7.38"
  instance_class      = "db.t3.small"
  allocated_storage   = 5
  skip_final_snapshot = true

  db_name  = "wp"
  username = "wp"
  port     = "3306"
  password = "please-change-me"

  # DB security group
  vpc_security_group_ids = [module.rds_security_group.security_group_id]

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"
}