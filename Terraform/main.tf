locals {
  instance_names = [
    "jenkins-server",
    "monitoring-server",
    "kubernetes-master-node",
    "kubernetes-worker-node"
  ]
}


# data "aws_ami" "amazon_linux_2" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
# }

# Key Generation and Storage
resource "tls_private_key" "web_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "web_key" {
  key_name   = "web_key"
  public_key = tls_private_key.web_key.public_key_openssh
}

# Save private key locally (with proper permissions)
resource "local_file" "private_key" {
  content         = tls_private_key.web_key.private_key_pem
  filename        = "${path.cwd}/web_key.pem"
  file_permission = "0400" # More secure permission
}

# Save public key locally
resource "local_file" "public_key" {
  content         = tls_private_key.web_key.public_key_openssh
  filename        = "${path.cwd}/web_key.pub"
  file_permission = "0644"
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS Account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "ec2" {
  count                  = var.ec2-instance-count
  ami                    = data.aws_ami.ubuntu.id
  subnet_id              = aws_subnet.public-subnet[count.index].id
  instance_type          = var.ec2_instance_type[count.index]
  vpc_security_group_ids = [aws_security_group.default-ec2-sg.id]
  key_name               = aws_key_pair.web_key.key_name
  root_block_device {
    volume_size = var.ec2_volume_size
    volume_type = var.ec2_volume_type
  }

  tags = {
    Name = "${local.org}-${local.project}-${local.env}-${local.instance_names[count.index]}"
    Env  = "${local.env}"
  }
}


# Output the private key path for reference
output "private_key_path" {
  value = local_file.private_key.filename
}

output "public_key_path" {
  value = local_file.public_key.filename
}

output "ssh_connection_example" {
  value = format("ssh -i %s ubuntu@%s", local_file.private_key.filename, aws_instance.ec2[0].public_ip)
}
