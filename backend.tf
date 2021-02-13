
data "template_file" "backend" {
  template = file(var.backend.userdata)
  vars = {
    url_demovip_server = var.backend.url_demovip_server
    username = var.backend.username
  }
}

resource "aws_instance" "backend" {
  count = length(data.aws_availability_zones.available.names)
  instance_type = var.backend.type
  ami = data.aws_ami.ubuntuBionic.id
  user_data = data.template_file.backend.rendered
  key_name = aws_key_pair.kpBackend.id
  vpc_security_group_ids = [aws_security_group.sgBackend.id]
  subnet_id = aws_subnet.subnetBackend[count.index].id

  tags = {
    Name = "backend-${count.index + 1 }"
    group = "backend"
    createdBy = "Terraform"
  }

}