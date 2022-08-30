# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/4.9.0
module "alb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "alb-security-group-${var.env}"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

# https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/7.0.0
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "7.0.0"

  name               = "${var.env}-alb"
  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.alb_security_group.security_group_id]

  ## Attach ec2 instances from ec2.tf to alb target group

  target_groups = [
    {
      name_prefix      = "alb-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = {
        web-za-01 = {
          target_id = element(values(module.ec2_za)[*].id, 0)
        }
        web-zb-01 = {
          target_id = element(values(module.ec2_zb)[*].id, 0)
          port      = 80
        }
        web-za-02 = {
          target_id = element(values(module.ec2_za)[*].id, 1)
        }
        web-zb-02 = {
          target_id = element(values(module.ec2_zb)[*].id, 1)
          port      = 80
        }
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}