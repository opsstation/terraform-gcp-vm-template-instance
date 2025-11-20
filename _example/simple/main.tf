provider "google" {
  project = "opsstation"
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}

#####==============================================================================
##### vpc module call.
#####==============================================================================
module "vpc" {
  source                                    = "opsstation/vpc/gcp"
  version                                   = "1.0.1"
  name                                      = "vpc"
  environment                               = "OpsStation"
  label_order                               = ["name", "environment"]
  mtu                                       = 1460
  routing_mode                              = "REGIONAL"
  network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
  network_enabled                           = true
  delete_default_routes_on_create           = false
}

#####==============================================================================
##### subnet module call.
#####==============================================================================
module "subnet" {
  source  = "opsstation/subnet/gcp"
  version = "1.0.1"
  name = [
    "subnet-public-1",
    "subnet-private-1",
  ]
  environment   = "nonprod"
  region        = "asia-northeast1"
  subnet_type   = ["public", "private"]
  network       = module.vpc.vpc_id
  ip_cidr_range = ["10.10.1.0/24", "10.10.2.0/24"]
  log_config = {
    enable               = true
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
    metadata_fields      = []
    filter_expr          = null
  }
}

#####==============================================================================
##### firewall module call.
#####==============================================================================
module "firewall" {
  source      = "opsstation/firewall/gcp"
  version     = "1.0.1"
  name        = "firewall"
  environment = "OpsStation"
  network     = module.vpc.vpc_id
  ingress_rules = [
    {
      name          = "allow-tcp-http-ingress"
      description   = "Allow TCP, HTTP ingress traffic"
      disabled      = false
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["22", "80"]
        }
      ]
    }
  ]
}

#####==============================================================================
##### compute_instance module call.
#####==============================================================================
module "simple_template" {
  source               = "./../../"
  name                 = "dev"
  environment          = "test"
  stack_type           = "IPV4_ONLY"
  region               = "asia-northeast1"
  source_image         = "ubuntu-2204-jammy-v20230908"
  source_image_family  = "ubuntu-2204-lts"
  source_image_project = "ubuntu-os-cloud"
  disk_size_gb         = "20"
  subnetwork           = module.subnet.subnet_self_link_public
  instance_template    = true
  service_account      = null
  enable_public_ip     = true ## public IP if enable_public_ip is true
  metadata = {
    ssh-keys = <<EOF
        dev:ssh-rsa AAAAB3NzaC1yc2EAA/3mwt2y+PDQMU= suresh@suresh
      EOF
  }
}