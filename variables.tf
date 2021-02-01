# AWS  variables

variable "avi_password" {}
variable "avi_username" {}

variable "public_key_path" {
  default = "~/.ssh/cloudKey.pub"
}

variable "jump" {
  type = map
  default = {
    type = "t2.medium"
    userdata = "userdata/jump.sh"
    count = "1"
    avisdkVersion = "18.2.9"
    username = "ubuntu"
    hostname = "jump"
  }
}

variable "ansible" {
  type = map
  default = {
    version = "2.9.12"
    prefixGroup = "aws"
    aviPbAbsentUrl = "https://github.com/tacobayle/ansiblePbAviAbsent"
    aviPbAbsentTag = "v1.43"
    directory = "ansible"
    aviConfigureTag = "v4.01"
    aviConfigureUrl = "https://github.com/tacobayle/aviConfigure"
    opencartInstallUrl = "https://github.com/tacobayle/ansibleOpencartInstall"
    opencartInstallTag = "v1.19"
  }
}

variable "backend" {
  type = map
  default = {
    type = "t2.micro"
    userdata = "userdata/backend.sh"
    count = "3"
  }
}

variable "opencart" {
  type = map
  default = {
    type = "t2.medium"
    userdata = "userdata/opencart.sh"
    count = "2"
    opencartDownloadUrl = "https://github.com/opencart/opencart/releases/download/3.0.3.5/opencart-3.0.3.5.zip"
  }
}

variable "mysql" {
  type = map
  default = {
    type = "t2.medium"
    userdata = "userdata/mysql.sh"
    count = "1"
  }
}

variable "autoScalingGroupUserdata" {
  default = "userdata/backendGroup.sh"
}

variable "controller" {
  default = {
    environment = "AWS"
    dns =  ["8.8.8.8", "8.8.4.4"]
    ntp = ["95.81.173.155", "188.165.236.162"]
    hostname = "controller"
    count = "1"
    type = "t2.2xlarge"
    version = "20.1.2"
    from_email = "avicontroller@avidemo.fr"
    se_in_provider_context = "false"
    tenant_access_to_provider_se = "true"
    tenant_vrf = "false"
    aviCredsJsonFile = "~/.creds.json"
  }
}

variable "privateKey" {
  default = "~/.ssh/cloudKey"
}

variable "aws" {
  default = {
    name = "cloudAws"
    region = "eu-west-1"
    vpc = {
      cidr = ["10.0.0.0/18"]
    }
    domains = [
      {
        name = "aws.avidemo.fr"
      }
    ]
    network_vip = [
      {
        cidr = "10.0.11.0/24"
      },
      {
        cidr = "10.0.12.0/24"
      },
      {
        cidr = "10.0.13.0/24"
      }
    ]
    management_network = [
      {
        cidr = "10.0.40.0/24"
      },
      {
        cidr = "10.0.50.0/24"
      },
      {
        cidr = "10.0.60.0/24"
      }
    ]
    network_backend = [
      {
        cidr = "10.0.4.0/24"
      },
      {
        cidr = "10.0.5.0/24"
      },
      {
        cidr = "10.0.6.0/24"
      }
    ]
    network_mysql = {
      cidr = "10.0.20.0/24"
    }
    network_admin = {
      cidr = "10.0.0.0/24"
    }
    serviceEngineGroup = [
      {
        name = "Default-Group"
        ha_mode = "HA_MODE_SHARED"
        min_scaleout_per_vs = 1
        buffer_se = 0
        instance_flavor = "t3.large"
        realtime_se_metrics = {
          enabled = true
          duration = 0
        }
      },
      {
        name = "seGroupCpuAutoScale"
        ha_mode = "HA_MODE_SHARED"
        min_scaleout_per_vs = 1
        buffer_se = 1
        instance_flavor = "t2.micro"
        extra_shared_config_memory = 0
        auto_rebalance = true
        auto_rebalance_interval = 30
        auto_rebalance_criteria = [
          "SE_AUTO_REBALANCE_CPU"
        ]
        realtime_se_metrics = {
          enabled = true
          duration = 0
        }
      },
      {
        name: "seGroupGslb"
        ha_mode = "HA_MODE_SHARED"
        min_scaleout_per_vs: 1
        buffer_se: 0
        instance_flavor = "t3.large"
        extra_shared_config_memory = 2000
        realtime_se_metrics = {
          enabled: true
          duration: 0
        }
      }
    ]
    pool = {
      name = "pool1"
      lb_algorithm = "LB_ALGORITHM_ROUND_ROBIN"
    }
    pool_opencart = {
      name = "pool_opencart"
      lb_algorithm = "LB_ALGORITHM_ROUND_ROBIN"
    }
    pool_asg = {
      name = "pool2BasedOnASG"
      lb_algorithm = "LB_ALGORITHM_ROUND_ROBIN"
    }
    virtualservices = {
      http = [
        {
          name = "app1"
          pool_ref = "pool1"
          services: [
            {
              port = 80
              enable_ssl = "false"
            },
            {
              port = 443
              enable_ssl = "true"
            }
          ]
        },
        {
          name = "app2-basedOnAsg"
          pool_ref = "pool2BasedOnASG"
          services: [
            {
              port = 443
              enable_ssl = "true"
            }
          ]
        },
        {
          name = "opencart"
          pool_ref = "pool_opencart"
          services: [
            {
              port = 80
              enable_ssl = "false"
            },
            {
              port = 443
              enable_ssl = "true"
            }
          ]
        }
      ]
      dns = [
        {
          name = "app3-dns"
          services: [
            {
              port = 53
            }
          ]
        },
        {
          name = "app4-gslb"
          services: [
            {
              port = 53
            }
          ]
          se_group_ref: "seGroupGslb"
        },
      ]
    }
  }
}