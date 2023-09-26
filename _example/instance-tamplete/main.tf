provider "google" {
  project = "opz0-397319"
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}

######==============================================================================
###### vpc module call.
######==============================================================================

module "vpc" {
  source                                    = "git::git@github.com:opsstation/terraform-gcp-vpc.git?ref=master"
  name                                      = "app"
  environment                               = "test"
  label_order                               = ["name", "environment"]
  project                                   = "opz0-397319"
  network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
}

######==============================================================================
###### subnet module call.
######==============================================================================
module "subnet" {
  source        = "git::git@github.com:opsstation/terraform-gcp-subnet.git?ref=master"
  name          = "subnet"
  environment   = "test"
  gcp_region    = "asia-northeast1"
  network       = module.vpc.vpc_id
  project_id    = "opz0-397319"
  source_ranges = ["10.10.0.0/16"]
}

######==============================================================================
##### firewall module call.
#####==============================================================================
module "firewall" {
  source        = "git::git@github.com:opsstation/terraform-gcp-firewall.git?ref=master"
  name          = "app"
  environment   = "test"
  project_id    = "opz0-397319"
  network       = module.vpc.vpc_id
  source_ranges = ["0.0.0.0/0"]

  allow = [
    { protocol = "tcp"
      ports    = ["22", "80"]
    }
  ]
}

#####==============================================================================
##### instance_template module call.
#####==============================================================================

module "instance_template" {
  source               = "../../"
  instance_template    = true
  name                 = "template"
  environment          = "test"
  region               = "asia-northeast1"
  project_id           = "opz0-397319"
  source_image         = "ubuntu-2204-jammy-v20230908"
  source_image_family  = "ubuntu-2204-lts"
  source_image_project = "ubuntu-os-cloud"
  subnetwork           = module.subnet.subnet_id
  service_account      = null
  metadata = {
    ssh-keys = <<EOF
      dev:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCx9HrdPJD7zv9SJlAKlssHr2CUSvifRBy+bRp2jRvP851p8RiMshlbrkaRAJV7gh0AFAxL6S7znWzGwFQZFv/XP9fEqD8B7XEOtVIZK+99AYRZfkO62WG5BR6vmN1u3ei2zHSY2IuCmita27BOaimfUCXFdPMUMXwKoTMvThK6UVKaoa+IWR7qkG0b7ByLKZBTsCgBlXH4xLkZsFdCsEDWog4ZJcY5F2tPwZkHoqI0g45CcJMlsfC1KMOkN0MLPAR/iR/wfsQ9Zp0GGFwAn3uJXrcAjUGv1/+giw7RYEnmR3PA5CpzuTNJrnNI2KoFUmh7HSRt5atNg0AEj+043I7B23/yKNBaiqqaNSiv5/qO29n1eSkDhQ7l2sLxAcMS3PkTMKcsf89KkqHDt8AEBWUuCPwVTrsSwAF1Fcfj4Fe4LQUYogM5d+Y3u95LdaaCizM8i/RJ0R6aR//OLtvlHeGJFVjSPiazVJea8ZvR+4nO4b67ic6YZvwfVCEUw+ttbb0= kamal@kamal
    EOF
  }
}

#####==============================================================================
##### compute_instance module call.
#####==============================================================================
module "compute_instance" {
  source                   = "../../"
  instance_from_template   = true
  name                     = "instance"
  environment              = "test"
  project_id               = "opz0-397319"
  region                   = "asia-northeast1"
  zone                     = "asia-northeast1-a"
  subnetwork               = module.subnet.subnet_id
  num_instances            = "1"
  source_instance_template = module.instance_template.self_link_unique
  deletion_protection      = false
  service_account          = null

  access_config = [{
    nat_ip       = ""
    network_tier = ""
  }, ]
}