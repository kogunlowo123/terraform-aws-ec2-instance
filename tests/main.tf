terraform {
  required_version = ">= 1.7.0"
}

module "test" {
  source = "../"

  name          = "test-instance"
  instance_type = "t3.micro"
  subnet_id     = "subnet-0123456789abcdef0"
  vpc_id        = "vpc-0123456789abcdef0"

  create_iam_instance_profile = true
  enable_ssm                  = true
  enable_monitoring           = true
  ebs_optimized               = true
  associate_public_ip         = false

  root_block_device = {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }

  create_security_group = true
  ingress_rules = [
    {
      description = "Allow SSH from VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
    }
  ]

  metadata_http_tokens = "required"
  metadata_hop_limit   = 1

  tags = {
    Test = "true"
  }
}
