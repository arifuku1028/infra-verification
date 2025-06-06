output "key_pair_name" {
  value = aws_key_pair.bastion.key_name
}

output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}

output "bastion_ssh_command" {
  value = <<-EOT
    ssh -i ${local_file.private_key.filename} \
    ec2-user@${aws_instance.bastion.private_ip} \
    -o ProxyCommand='aws ec2-instance-connect open-tunnel --instance-id ${aws_instance.bastion.id}'
  EOT
}
