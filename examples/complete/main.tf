provider "aws" {
  region = "us-east-1"
}

################################################################################
# VPC (for demonstration - use your own VPC in production)
################################################################################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

################################################################################
# KMS Key for EBS encryption
################################################################################

resource "aws_kms_key" "ebs" {
  description             = "KMS key for EBS volume encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.tags
}

resource "aws_kms_alias" "ebs" {
  name          = "alias/complete-example-ebs"
  target_key_id = aws_kms_key.ebs.key_id
}

################################################################################
# Additional Security Group
################################################################################

resource "aws_security_group" "additional" {
  name_prefix = "complete-example-additional-"
  description = "Additional security group for complete example"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Custom app port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  tags = local.tags
}

################################################################################
# Additional IAM Policy
################################################################################

resource "aws_iam_policy" "custom" {
  name_prefix = "complete-example-custom-"
  description = "Custom policy for complete example"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Resource = [
          "arn:aws:s3:::my-application-bucket",
          "arn:aws:s3:::my-application-bucket/*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:my-app/*"
      }
    ]
  })

  tags = local.tags
}

################################################################################
# Locals
################################################################################

locals {
  tags = {
    Environment = "production"
    Project     = "complete-example"
    Team        = "platform"
    ManagedBy   = "terraform"
  }
}

################################################################################
# EC2 Instance Module - On-Demand
################################################################################

module "ec2_instance" {
  source = "../../"

  name          = "complete-example"
  ami_id        = data.aws_ami.amazon_linux.id
  instance_type = "m6i.xlarge"
  subnet_id     = data.aws_subnets.default.ids[0]
  vpc_id        = data.aws_vpc.default.id
  key_name      = "my-key-pair"

  # Placement
  tenancy = "default"

  # Monitoring and optimization
  enable_monitoring = true
  ebs_optimized     = true

  # Networking
  associate_public_ip = false

  # IMDSv2 enforced
  metadata_http_tokens = "required"
  metadata_hop_limit   = 2

  # Root volume with KMS encryption
  root_block_device = {
    volume_type = "gp3"
    volume_size = 100
    iops        = 3000
    throughput  = 250
    encrypted   = true
    kms_key_id  = aws_kms_key.ebs.arn
  }

  # Additional EBS volumes
  additional_ebs_volumes = [
    {
      device_name = "/dev/xvdb"
      volume_type = "gp3"
      volume_size = 500
      iops        = 6000
      throughput  = 250
      encrypted   = true
      kms_key_id  = aws_kms_key.ebs.arn
    }
  ]

  # Security groups
  create_security_group = true
  security_group_ids    = [aws_security_group.additional.id]
  ingress_rules = [
    {
      description = "SSH from bastion"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    },
    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
    },
  ]

  # IAM
  create_iam_instance_profile = true
  enable_ssm                  = true
  iam_policies = [
    aws_iam_policy.custom.arn,
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  ]

  # User data
  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    # Update system
    dnf update -y

    # Install CloudWatch agent
    dnf install -y amazon-cloudwatch-agent

    # Configure CloudWatch agent
    cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'CONFIG'
    {
      "metrics": {
        "metrics_collected": {
          "mem": { "measurement": ["mem_used_percent"] },
          "disk": { "measurement": ["used_percent"], "resources": ["*"] }
        }
      },
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              { "file_path": "/var/log/messages", "log_group_name": "complete-example/messages" },
              { "file_path": "/var/log/secure", "log_group_name": "complete-example/secure" }
            ]
          }
        }
      }
    }
    CONFIG

    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config -m ec2 \
      -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

    # Format and mount additional EBS volume
    while [ ! -b /dev/xvdb ]; do sleep 1; done
    mkfs -t xfs /dev/xvdb
    mkdir -p /data
    mount /dev/xvdb /data
    echo '/dev/xvdb /data xfs defaults,nofail 0 2' >> /etc/fstab
  EOF

  tags = local.tags
}

################################################################################
# Spot Instance Module
################################################################################

module "spot_instance" {
  source = "../../modules/spot"

  name          = "complete-example-spot"
  ami_id        = data.aws_ami.amazon_linux.id
  instance_type = "m6i.large"
  subnet_id     = data.aws_subnets.default.ids[0]
  vpc_id        = data.aws_vpc.default.id

  security_group_ids        = [aws_security_group.additional.id]
  iam_instance_profile_name = module.ec2_instance.iam_instance_profile_name

  spot_type                      = "one-time"
  instance_interruption_behavior = "terminate"

  root_volume_size = 50

  tags = local.tags
}

################################################################################
# Outputs
################################################################################

output "instance_id" {
  description = "On-demand instance ID"
  value       = module.ec2_instance.instance_id
}

output "private_ip" {
  description = "On-demand instance private IP"
  value       = module.ec2_instance.private_ip
}

output "security_group_id" {
  description = "Primary security group ID"
  value       = module.ec2_instance.security_group_id
}

output "iam_role_arn" {
  description = "IAM role ARN"
  value       = module.ec2_instance.iam_role_arn
}

output "spot_instance_id" {
  description = "Spot instance ID"
  value       = module.spot_instance.instance_id
}

output "spot_private_ip" {
  description = "Spot instance private IP"
  value       = module.spot_instance.private_ip
}
