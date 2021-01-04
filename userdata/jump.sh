#!/bin/bash
#
# Tested for ubbuntu 20.04
#
sudo apt-get update
sudo apt-get -y install python
sudo apt install -y python3-pip
sudo apt install -y jq
pip3 install ansible==${ansibleVersion}
pip3 install avisdk==${avisdkVersion}
pip3 install dnspython
pip3 install boto3
pip3 install botocore
sudo -u ubuntu ansible-galaxy install -f avinetworks.avisdk
sudo mkdir -p /opt/ansible/inventory
sudo tee /opt/ansible/inventory/aws_ec2.yaml > /dev/null <<EOT
---
plugin: aws_ec2
keyed_groups:
  - key: tags
    prefix: ${ansiblePrefixGroup}
EOT
sudo mkdir -p /etc/ansible
sudo tee /etc/ansible/ansible.cfg > /dev/null <<EOT
[defaults]
inventory      = /opt/ansible/inventory/aws_ec2.yaml
private_key_file = /home/${username}/.ssh/${basename(privateKey)}
host_key_checking = False
host_key_auto_add = True
EOT
echo "cloud init done" | tee /tmp/cloudInitDone.log
