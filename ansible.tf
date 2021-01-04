resource "null_resource" "foo7" {
  depends_on = [aws_instance.jump]
  connection {
    host        = aws_instance.jump.public_ip
    type        = "ssh"
    agent       = false
    user        = var.jump["username"]
    private_key = file(var.privateKey)
  }

  provisioner "file" {
    source      = var.privateKey
    destination = "~/.ssh/${basename(var.privateKey)}"
  }

  provisioner "file" {
    source      = var.ansible["directory"]
    destination = "~/ansible"
  }

  provisioner "file" {
    content      = <<EOF
---
mysql_db_hostname: ${aws_instance.mysql[0].private_ip}

controller:
  environment: ${var.controller["environment"]}
  username: ${var.avi_user}
  password: ${var.avi_password}
  name: ${data.aws_ami.aviAmi.name}
  count: ${var.controller["count"]}
  version: ${var.controller["version"]}
  from_email: ${var.controller["from_email"]}
  se_in_provider_context: ${var.controller["se_in_provider_context"]}
  tenant_access_to_provider_se: ${var.controller["tenant_access_to_provider_se"]}
  tenant_vrf: ${var.controller["tenant_vrf"]}
  aviCredsJsonFile: ${var.controller["aviCredsJsonFile"]}

controllerPrivateIps:
${yamlencode(aws_instance.aviCtrl.*.private_ip)}

controllerPublicIps:
${yamlencode(aws_instance.aviCtrl.*.public_ip)}

ntpServers:
${yamlencode(var.controller["ntp"].*)}

dnsServers:
${yamlencode(var.controller["dns"].*)}

domain:
  name: ${var.domain["name"]}

aws:
  region: ${var.regionAws}
  vpc_id: ${aws_vpc.vpc[0].id}
  cloudName: &cloud0 ${var.avi_cloud["name"]}

awsZones:
${yamlencode(data.aws_availability_zones.available.names)}

awsSubnetSeMgtIds:
${yamlencode(aws_subnet.subnetAviSeMgt.*.id)}

awsSubnetSeMgtCidrs:
${yamlencode(var.cidrSubnetAviSeMgt)}

awsSubnetAviVsCidrs:
${yamlencode(var.cidrSubnetAviVs)}

awsSubnetAviVsIds:
${yamlencode(aws_subnet.subnetAviVs.*.id)}



avi_applicationprofile:
  http:
    - name: &appProfile0 applicationProfileOpencart

avi_servers:
${yamlencode(aws_instance.backend.*.private_ip)}

avi_servers_open_cart:
${yamlencode(aws_instance.opencart.*.private_ip)}

avi_serverautoscalepolicy:
  - name: &autoscalepolicy0 autoscalepolicyAsg
    min_size: 2
    max_size: 2
    max_scaleout_adjustment_step: 2
    max_scalein_adjustment_step: 2
    scaleout_cooldown: 30
    scalein_cooldown: 30

avi_pool:
  name: ${var.avi_pool["name"]}
  lb_algorithm: ${var.avi_pool["lb_algorithm"]}
  cloud_ref: ${var.avi_cloud["name"]}

avi_pool_group:
  - name: ${var.avi_pool_group["name"]}
    cloud_ref: ${var.avi_cloud["name"]}
    autoscale_policy_ref: *autoscalepolicy0
    external_autoscale_groups: ${aws_autoscaling_group.autoScalingGroup.id}
    lb_algorithm: ${var.avi_pool_group["lb_algorithm"]}

avi_pool_open_cart:
  application_persistence_profile_ref: ${var.avi_pool_opencart["application_persistence_profile_ref"]}
  name: ${var.avi_pool_opencart["name"]}
  lb_algorithm: ${var.avi_pool_opencart["lb_algorithm"]}
  cloud_ref: ${var.avi_cloud["name"]}


avi_gslb:
  dns_configs:
    - domain_name: ${var.avi_gslb["domain"]}

authProfile:
  - name: authProfile1
    type: AUTH_PROFILE_SAML
    saml:
      sp:
        saml_entity_type: AUTH_SAML_APP_VS

ssoPolicy:
  - name: ssoPolicy1
    type: SSO_TYPE_SAML

EOF
    destination = var.ansible["yamlFile"]
  }

  provisioner "file" {
    content      = <<EOF
{"serviceEngineGroup": ${jsonencode(var.serviceEngineGroup)}, "avi_virtualservice": ${jsonencode(var.avi_virtualservice)}}
EOF
    destination = var.ansible["jsonFile"]
  }

  provisioner "remote-exec" {
    inline      = [
      "chmod 600 ~/.ssh/${basename(var.privateKey)}",
      "cd ~/ansible ; git clone ${var.ansible["opencartInstallUrl"]} --branch ${var.ansible["opencartInstallTag"]} ; ansible-playbook ansibleOpencartInstall/local.yml --extra-vars @${var.ansible["yamlFile"]}",
      "cd ~/ansible ; git clone ${var.ansible["aviConfigureUrl"]} --branch ${var.ansible["aviConfigureTag"]} ; ansible-playbook aviConfigure/local.yml --extra-vars @${var.ansible["yamlFile"]} --extra-vars @${var.ansible["jsonFile"]}",
    ]
  }

}
