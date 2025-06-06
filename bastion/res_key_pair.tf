
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "bastion" {
  key_name   = "${local.prefix}-bastion-key"
  public_key = tls_private_key.bastion.public_key_openssh

  tags = {
    Name = "${local.prefix}-bastion-key"
  }
}

resource "local_file" "public_key" {
  filename        = "${path.module}/bastion_key/public_key"
  content         = tls_private_key.bastion.public_key_openssh
  file_permission = "0600"
}

resource "local_file" "private_key" {
  filename        = "${path.module}/bastion_key/private_key.pem"
  content         = tls_private_key.bastion.private_key_pem
  file_permission = "0600"
}

