
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ssh" {
  key_name   = "${local.prefix}-ssh-key-pair"
  public_key = tls_private_key.ssh.public_key_openssh

  tags = {
    Name = "${local.prefix}-ssh-key-pair"
  }
}

resource "local_file" "public_key" {
  filename        = "${path.module}/ssh_key/public_key"
  content         = tls_private_key.ssh.public_key_openssh
  file_permission = "0600"
}

resource "local_file" "private_key" {
  filename        = "${path.module}/ssh_key/private_key.pem"
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "0600"
}

