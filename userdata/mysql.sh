#!/bin/bash
#
# Validated for Ubuntu 18.04
#
#!/bin/bash
sudo apt-get update
sudo apt install -y mysql-server
sudo apt install -y python-pip
sudo apt install -y python-pip3
pip install PyMySQL
pip3 install PyMySQL
echo "cloud init done" | tee /tmp/cloudInitDone.log
