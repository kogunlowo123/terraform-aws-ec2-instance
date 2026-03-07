# Basic Example

This example demonstrates the minimal configuration required to launch an EC2 instance using the module.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## What this creates

- EC2 instance with Amazon Linux 2023 AMI (auto-selected)
- Launch template with IMDSv2 enforced
- IAM instance profile with SSM and CloudWatch policies
- Security group with egress-only rules
- EBS-optimized instance with encrypted root volume

## Notes

- Replace `subnet_id` and `vpc_id` with your actual values
- The module defaults to `t3.micro` instance type
- Detailed monitoring is enabled by default
