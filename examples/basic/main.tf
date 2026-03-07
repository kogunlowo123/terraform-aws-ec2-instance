provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
  source = "../../"

  name          = "basic-example"
  instance_type = "t3.micro"
  subnet_id     = "subnet-0123456789abcdef0"
  vpc_id        = "vpc-0123456789abcdef0"

  tags = {
    Environment = "dev"
    Project     = "basic-example"
  }
}

output "instance_id" {
  value = module.ec2_instance.instance_id
}

output "private_ip" {
  value = module.ec2_instance.private_ip
}
