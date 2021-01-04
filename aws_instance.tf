# Retrieve AMi details

data "aws_ami" "aviAmi" {
  owners           = ["aws-marketplace"]
  most_recent      = true

  filter {
    name   = "name"
    values = ["Avi-Controller-${var.controller["version"]}*"]
  }

}

data "aws_ami" "ubuntuBionic" {
  owners           = ["099720109477"]
  most_recent      = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

}

data "aws_ami" "ubuntuFocal" {
  owners           = ["099720109477"]
  most_recent      = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

}

# Avi Controller creation

resource "aws_instance" "aviCtrl" {
  count = var.controller["count"]
  instance_type = var.controller["type"]
  ami = data.aws_ami.aviAmi.id
  key_name = aws_key_pair.kpAvi.id
  iam_instance_profile = aws_iam_instance_profile.AviController-Instance-Profile.name
  vpc_security_group_ids = [aws_security_group.sgAvi.id]
  subnet_id = aws_subnet.subnetMgt.id

  tags = {
  Name = "Avi Controller-${count.index + 1 }"
  group = "controller"
  createdBy = "Terraform"
  }

}

resource "aws_instance" "backend" {
  count = length(data.aws_availability_zones.available.names)
  instance_type = var.backend["type"]
  ami = data.aws_ami.ubuntuBionic.id
  user_data = file(var.backend["userdata"])
  key_name = aws_key_pair.kpBackend.id
  vpc_security_group_ids = [aws_security_group.sgBackend.id]
  subnet_id = aws_subnet.subnetBackend[count.index].id

  tags = {
  Name = "backend-${count.index + 1 }"
  group = "backend"
  createdBy = "Terraform"
  }

}

resource "aws_launch_template" "templateAsg" {
  name_prefix   = "templateAsg"
  image_id      = data.aws_ami.ubuntuBionic.id
  instance_type = var.backend["type"]
  user_data = filebase64(var.autoScalingGroupUserdata)
  vpc_security_group_ids = [aws_security_group.sgBackend.id]
}

resource "aws_autoscaling_group" "autoScalingGroup" {
  vpc_zone_identifier = [aws_subnet.subnetBackend[0].id, aws_subnet.subnetBackend[1].id, aws_subnet.subnetBackend[2].id]
  desired_capacity   = 3
  max_size           = 5
  min_size           = 3

  launch_template {
    id      = aws_launch_template.templateAsg.id
    version = "$Latest"
  }

}

data "template_file" "opencart_userdata" {
  count = var.opencart["count"]
  template = file(var.opencart["userdata"])
  vars = {
    opencartDownloadUrl = var.opencart["opencartDownloadUrl"]
    domainName = var.avi_gslb["domain"]
  }
}

resource "aws_instance" "opencart" {
  count = var.opencart["count"]
  instance_type = var.opencart["type"]
  ami = data.aws_ami.ubuntuBionic.id
  user_data = data.template_file.opencart_userdata[count.index].rendered
  key_name = aws_key_pair.kpOpencart.id
  vpc_security_group_ids = [aws_security_group.sgOpencart.id]
  subnet_id = aws_subnet.subnetBackend[count.index].id

  tags = {
  Name = "opencart-${count.index + 1 }"
  group = "opencart"
  createdBy = "Terraform"
  }

}

resource "aws_instance" "mysql" {
  count = var.mysql["count"]
  instance_type = var.mysql["type"]
  ami = data.aws_ami.ubuntuBionic.id
  user_data = file(var.mysql["userdata"])
  key_name = aws_key_pair.kpMysql.id
  vpc_security_group_ids = [aws_security_group.sgMysql.id]
  subnet_id = aws_subnet.subnetMysql.id

  tags = {
  Name = "mySql-${count.index + 1 }"
  group = "mysql"
  createdBy = "Terraform"
  }

}

data "template_file" "jump" {
  template = file(var.jump["userdata"])
  vars = {
    avisdkVersion = var.jump["avisdkVersion"]
    ansibleVersion = var.ansible["version"]
    username = var.jump["username"]
    privateKey = var.privateKey
    ansiblePrefixGroup = var.ansible["prefixGroup"]
  }
}

# Create the jump server

resource "aws_instance" "jump" {
  instance_type = var.jump["type"]
  ami = data.aws_ami.ubuntuFocal.id
  key_name = aws_key_pair.kpJump.id
  iam_instance_profile = aws_iam_instance_profile.Ansible-Instance-Profile.name
  vpc_security_group_ids = [aws_security_group.sgJump.id]
  subnet_id = aws_subnet.subnetMgt.id
  user_data = data.template_file.jump.rendered
  tags = {
  Name = "jump"
  group = "jump"
  createdBy = "Terraform"
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    agent       = false
    user        = var.jump["username"]
    private_key = file(var.privateKey)
  }

  provisioner "remote-exec" {
    inline      = [
      "while [ ! -f /tmp/cloudInitDone.log ]; do sleep 1; done"
    ]
  }

}
