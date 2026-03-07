provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

module "ec2_instance" {
  source = "../../"

  name          = "advanced-example"
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = "m6i.large"
  subnet_id     = "subnet-0123456789abcdef0"
  vpc_id        = "vpc-0123456789abcdef0"
  key_name      = "my-key-pair"

  # Monitoring and optimization
  enable_monitoring = true
  ebs_optimized     = true

  # IMDSv2 enforced with hop limit of 2 (for containers)
  metadata_http_tokens = "required"
  metadata_hop_limit   = 2

  # Root volume configuration
  root_block_device = {
    volume_type = "gp3"
    volume_size = 50
    iops        = 3000
    throughput  = 125
    encrypted   = true
  }

  # Additional EBS volumes
  additional_ebs_volumes = [
    {
      device_name = "/dev/xvdb"
      volume_type = "gp3"
      volume_size = 100
      iops        = 3000
      encrypted   = true
    },
    {
      device_name = "/dev/xvdc"
      volume_type = "io2"
      volume_size = 200
      iops        = 10000
      encrypted   = true
    }
  ]

  # Security group with ingress rules
  create_security_group = true
  ingress_rules = [
    {
      description = "SSH from VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
    },
    {
      description = "HTTPS from VPC"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
    }
  ]

  # IAM with additional policies
  create_iam_instance_profile = true
  enable_ssm                  = true
  iam_policies = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  ]

  # User data
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y amazon-ssm-agent
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
  EOF

  tags = {
    Environment = "staging"
    Project     = "advanced-example"
    Team        = "platform"
  }
}

output "instance_id" {
  value = module.ec2_instance.instance_id
}

output "private_ip" {
  value = module.ec2_instance.private_ip
}

output "security_group_id" {
  value = module.ec2_instance.security_group_id
}

output "iam_role_arn" {
  value = module.ec2_instance.iam_role_arn
}
