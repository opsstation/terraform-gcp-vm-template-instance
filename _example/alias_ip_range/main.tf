provider "google" {
  project = "opsstation-474608"
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
  source        = "opsstation/subnet/gcp"
  version       = "1.0.1"
  name          = ["subnet"]
  environment   = "nonprod"
  region        = "asia-northeast1"
  network       = module.vpc.vpc_id
  ip_cidr_range = ["10.10.1.0/24"]
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
##### Single-service-account module call .
#####==============================================================================
module "service-account" {
  source  = "opsstation/service-account/gcp"
  version = "1.0.1"

  service_account = [
    {
      name          = "test"
      display_name  = "Single Service Account"
      description   = "Single Account Description"
      roles         = ["roles/viewer"] # Single role
      generate_keys = false
    }
  ]
}


#####==============================================================================
##### instance_template module call.
#####==============================================================================
module "instance_template" {
  source            = "./../../"
  name              = "alias-ip-range"
  environment       = "test"
  instance_template = true
  subnetwork        = module.subnet.subnet_id

  service_account = {
    email  = module.service-account.account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"] # Example scopes
  }

  alias_ip_range = {
    ip_cidr_range         = "/24"
    subnetwork_range_name = module.subnet.subnet_name
  }
}