output "az" {
  value = data.aws_availability_zones.available.names
}

output "aviAmi" {
  value = data.aws_ami.aviAmi.id
}

output "ubuntuBionic" {
  value = data.aws_ami.ubuntuBionic.id
}

output "ubuntuFocal" {
  value = data.aws_ami.ubuntuFocal.id
}

output "jumpPublicIp" {
  value = aws_instance.jump.public_ip
}

output "aviCtrlPublicIp" {
  value = aws_instance.aviCtrl.*.public_ip
}

output "destroy" {
  value = "ssh -o StrictHostKeyChecking=no -i ~/.ssh/${basename(var.privateKey)} -t ubuntu@${aws_instance.jump.public_ip} 'git clone ${var.ansible["aviPbAbsentUrl"]} --branch ${var.ansible["aviPbAbsentTag"]}; ansible-playbook ansiblePbAviAbsent/local.yml --extra-vars @${var.ansible["yamlFile"]} --extra-vars @${var.controller["aviCredsJsonFile"]} --extra-vars @${var.ansible["jsonFile"]}' ; sleep 20 ; terraform destroy -auto-approve"
  description = "command to destroy the infra"
}
