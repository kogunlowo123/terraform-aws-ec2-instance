# Spot Instance Sub-Module

This sub-module provisions EC2 Spot Instances with configurable spot options, launch templates, and IMDSv2 enforcement.

## Usage

```hcl
module "spot_instance" {
  source = "../../modules/spot"

  name          = "my-spot-instance"
  ami_id        = "ami-0123456789abcdef0"
  instance_type = "t3.medium"
  subnet_id     = "subnet-abc123"
  vpc_id        = "vpc-abc123"

  security_group_ids = ["sg-abc123"]

  spot_price = "0.05"
  spot_type  = "one-time"

  tags = {
    Environment = "dev"
  }
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name identifier for resources | string | - |
| ami_id | AMI ID for the spot instance | string | - |
| instance_type | Instance type | string | `t3.micro` |
| spot_price | Maximum spot price | string | `null` (on-demand) |
| spot_type | Spot request type | string | `one-time` |
| instance_interruption_behavior | Behavior on interruption | string | `terminate` |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | The ID of the spot instance |
| private_ip | The private IP address |
| public_ip | The public IP address |
| launch_template_id | The launch template ID |
