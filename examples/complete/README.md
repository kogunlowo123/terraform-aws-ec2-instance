# Complete Example

This example demonstrates a full production deployment using both on-demand and spot instances with all available features.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## What this creates

### On-Demand Instance
- EC2 `m6i.xlarge` with Amazon Linux 2023
- Launch template with IMDSv2 enforced
- 100 GB gp3 root volume with KMS encryption and custom IOPS/throughput
- 500 GB gp3 additional data volume with KMS encryption
- Security group with SSH and HTTPS ingress rules
- Additional security group for custom app port (8080)
- IAM instance profile with SSM, CloudWatch, S3 read-only, and custom policies
- CloudWatch agent installation and configuration via user data
- EBS volume formatting and mounting via user data

### Spot Instance
- EC2 `m6i.large` spot instance
- Shares IAM instance profile with on-demand instance
- One-time spot request with terminate on interruption
- 50 GB encrypted root volume

### Supporting Resources
- KMS key with rotation for EBS volume encryption
- Custom IAM policy for S3 and Secrets Manager access
- Additional security group for application traffic

## Notes

- This example uses the default VPC for simplicity; use dedicated VPCs in production
- Replace `key_name` with your actual key pair name
- The KMS key has a 7-day deletion window
- CloudWatch agent collects memory, disk, and log metrics
