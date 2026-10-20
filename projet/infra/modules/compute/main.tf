data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "app" {
  ami                    = data.aws_ssm_parameter.ami.value
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.instance_profile_name

  # Si l'installation réussit, l'accès sortant (NAT) fonctionne.
  user_data                   = <<-EOT
    #!/bin/bash
    dnf install -y nginx
    echo "<h1>${var.name} : instance applicative OK</h1>" > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  EOT
  user_data_replace_on_change = true

  metadata_options {
    http_tokens = "required"
  }
  root_block_device {
    encrypted = true
  }
  tags = { Name = "${var.name}-app" }
}
