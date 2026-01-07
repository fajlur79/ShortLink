
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "ShortLink-VPC"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

  tags = {
    Terraform   = "true"
    Environment = "production"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "ShortLink-Server-SG"
  description = "Allow HTTP from ALB"
  vpc_id      = module.vpc.vpc_id  # UPDATED: Use our new custom VPC

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    # We reference the ALB security group (defined in alb.tf)
    security_groups = [aws_security_group.lb_sg.id] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "aws-sl-key"
  public_key = file(pathexpand("~/.ssh/aws-sl.pub"))
}