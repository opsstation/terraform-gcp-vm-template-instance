provider "google" {
  project = "local-concord-408802"
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}
######==============================================================================
###### vpc module call.
######==============================================================================

module "vpc" {
  source                                    = "git::git@github.com:opsstation/terraform-gcp-vpc.git?ref=master"
  name                                      = "dev"
  environment                               = "test"
  label_order                               = ["name", "environment"]
  network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
}

######==============================================================================
###### subnet module call.
######==============================================================================
module "subnet" {
  source        = "git::git@github.com:opsstation/terraform-gcp-subnet.git?ref=master"
  name          = "dev"
  environment   = "test"
  gcp_region    = "asia-northeast1"
  network       = module.vpc.vpc_id
  ip_cidr_range = ["10.10.0.0/16"]
}

#####==============================================================================
##### firewall module call.
#####==============================================================================
module "firewall" {
  source        = "git::git@github.com:opsstation/terraform-gcp-firewall.git?ref=master"
  name          = "dev"
  environment   = "test"
  network       = module.vpc.vpc_id
  source_ranges = ["0.0.0.0/0"]

  allow = [
    { protocol = "tcp"
      ports    = ["22", "80"]
    }
  ]
}

#####==============================================================================
##### compute_instance module call.
#####==============================================================================
data "google_compute_instance_template" "generic" {
  name = "instance-temp"
}

module "compute_instance" {
  source                 = "../../"
  name                   = "dev"
  environment            = "instance"
  region                 = "asia-northeast1"
  zone                   = "asia-northeast1-a"
  subnetwork             = module.subnet.subnet_id
  instance_from_template = true
  deletion_protection    = false
  service_account        = null
  ## public IP if enable_public_ip is true
  enable_public_ip         = true
  source_instance_template = data.google_compute_instance_template.generic.self_link
}