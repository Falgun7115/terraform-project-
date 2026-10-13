# -----------------------------------------------------------------------------
# Compute Instance
# -----------------------------------------------------------------------------

# Always fetch the latest Amazon Linux 2023 AMI rather than hardcoding an AMI
# ID, which would go stale and vary by region.
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

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = var.key_pair_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  # Minimal bootstrap: installs and starts a basic web server so you have
  # something to curl / view in a browser once the instance is up.
  user_data = <<-EOF
    #!/bin/bash
    dnf install -y httpd
    systemctl enable httpd
    systemctl start httpd
    echo "<h1>Mini Project 3 - Terraform on AWS</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "${var.project_name}-instance"
  }
}
