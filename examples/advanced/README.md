# Advanced Example

This example demonstrates a production-grade EC2 instance configuration with custom AMI, multiple EBS volumes, security group rules, and IAM policies.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## What this creates

- EC2 instance with Ubuntu 24.04 AMI
- Launch template with IMDSv2 enforced (hop limit 2 for container support)
- 50 GB gp3 root volume with custom IOPS
- Two additional EBS volumes (100 GB gp3 + 200 GB io2)
- Security group with SSH and HTTPS ingress from VPC CIDR
- IAM instance profile with SSM, CloudWatch, and S3 read-only policies
- User data script for SSM agent installation
- EBS-optimized with detailed monitoring

## Notes

- Replace `subnet_id`, `vpc_id`, and `key_name` with your actual values
- Adjust CIDR blocks in ingress rules to match your network
- The io2 volume with 10,000 IOPS is suitable for database workloads
