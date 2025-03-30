data "aws_ami" "ubuntu-2004" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#resource "aws_key_pair" "ssh_key" {
#  key_name   = "${var.key_name}"
#  public_key = "${var.public_key}"
#}

resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.bastion_key.public_key_openssh
}

resource "aws_instance" "bastion_host" {
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[0]
  ami                         = data.aws_ami.ubuntu-2004.id
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.bastion_host_sg.id]
  key_name                    = var.key_name
  user_data                   = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname ${var.bastion_hostname}-host
sudo sed -i "s/#Port 22/Port ${var.bastion_port}/" /etc/ssh/sshd_config
sudo systemctl restart sshd
EOF

  tags = {
    Name = "BastionHost-${var.env}"
    Environment = var.env
  }

  depends_on = [
    aws_key_pair.generated_key
  ]
}
