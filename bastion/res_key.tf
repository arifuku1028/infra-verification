
resource "tls_private_key" "bastion" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "bastion" {
  key_name   = "${local.prefix}-bastion-key"
  public_key = tls_private_key.bastion.public_key_openssh
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

