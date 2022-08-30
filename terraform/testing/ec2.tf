# tạo ssh keypair cho ec2 instance, https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "devops" {
  key_name = "devops-ssh"

  # replace the below with your public key
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDtXkVio4iq8MFEg7XZiZGAT4h+23ksxNTJ1HNAKfVdMICFpGxAzGXVrk48deQ4PB4+wUiCgwma87aKEPDfI5uLormyv1COZKjoDntbbzk9FFbMpQ+1WHJDa6udZxNuTY2bIhaZuH1BavKPZWDZHLxOSvmrYNb5qy+NrqKIFtG1tsF/sUnZZqrMlF2UPJ/LmSQL662kI6jgIoU4Fi4RSDdPIZabsPIgVn81QhQ3ipA3gzcsINhuw1n9clrISZD6O9Z2kUNic5wwfgLEbpk3ADKmX/tZwsAm05f5aauETTa2a1CzJVd4OiffJEQIyaXbJxnTWtUVRNOSPs1eT6AciWocV6hK+kilJZNqok8PXMzS4rr9QILkJbVCpa/79dFqlVBxhee4J7XbpUaVpWAV2yuBZspm9n7wHpxNsBPxWopY3YxGJeQNWrq/L40zAqJnL08IQVnRxfWKKLyXrmK8QZDPWdDXxp4qHRc75mW7unQDsQHYYmE4Up+RWu1BwynSy3Qg22Y2oYej+Ktlnz/GV+IXbLA7KLg9Op9mOvGu+XSxBrqqNj3wQoB3vtlSFn3zs7Y2E14vm8Y+vYy7pnHG57sr/mRyqjkRVqM3v2xAmXBNUgjfMKLGhzobuUsCmPx3IC8+1yVksZKOoRWtlwWUvOdVjEjG7KdkJhlbX9ix9PTTWQ== sonvt8@viettel.com.vn"
}

# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/4.9.0
module "ec2_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "web-security-group-${var.env}"
  description = "Security group for Web ec2 instances"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp", "ssh-tcp"]
  egress_rules        = ["all-all"]
}

## EC2 https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws

# tạo ec2 instances ở public subnet, zone-a
module "ec2_za" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(["01","02"])

  name = "${var.env}-web-za-${each.key}"

  ami                    = "ami-0eaf04122a1ae7b3b" # https://cloud-images.ubuntu.com/locator/ec2/
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.devops.key_name
  vpc_security_group_ids = [module.ec2_security_group.security_group_id]
  subnet_id              = element(module.vpc.public_subnets, 0)

  tags = {
    Terraform   = "true"
    Environment = "${var.env}"
  }
}

# tạo ec2 instances ở public subnet, zone-b
module "ec2_zb" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(["01","02"])

  name = "${var.env}-web-zb-${each.key}"

  ami                    = "ami-0eaf04122a1ae7b3b" # https://cloud-images.ubuntu.com/locator/ec2/
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.devops.key_name
  vpc_security_group_ids = [module.ec2_security_group.security_group_id]
  subnet_id              = element(module.vpc.public_subnets, 1)

  tags = {
    Terraform   = "true"
    Environment = "${var.env}"
  }
}