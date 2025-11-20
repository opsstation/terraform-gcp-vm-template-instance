# 🏗️ Terraform-google-template-instance
# Terraform Google Cloud Template-instance Module

[![OpsStation](https://img.shields.io/badge/Made%20by-OpsStation-blue?style=flat-square&logo=terraform)](https://www.opsstation.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-1.13%2B-purple.svg?logo=terraform)](#)
[![CI](https://github.com/OpsStation/terraform-gcp-vm-template-instance/actions/workflows/ci.yml/badge.svg)](https://github.com/OpsStation/terraform-gcp-vm-template-instance/actions/workflows/ci.yml)
[![Latest Release](https://img.shields.io/github/release/opsstation/terraform-gcp-vm-template-instance.svg)](https://github.com/opsstation/terraform-gcp-vm-template-instance/releases/latest)

> 🌩️ **A production-grade, reusable GCP Subnet module by [OpsStation](https://www.opsstation.com)**
> Designed for reliability, performance, and security — following GCP networking best practices.
---

## 🏢 About OpsStation

**OpsStation** delivers **Cloud & DevOps excellence** for modern teams:
- 🚀 **Infrastructure Automation** with Terraform, Ansible & Kubernetes
- 💰 **Cost Optimization** via scaling & right-sizing
- 🛡️ **Security & Compliance** baked into CI/CD pipelines
- ⚙️ **Fully Managed Operations** across GCP, Azure, and AWS

> 💡 Need enterprise-grade DevOps automation?
> 👉 Visit [**www.opsstation.com**](https://www.opsstation.com) or email **hello@opsstation.com**

---
:

🌟 Features

✅ Creates highly configurable GCE Instance Templates with full control over machine type, disks, network, labels, and metadata

✅ Supports **custom labels** using [OpsStation multicloud module](https://registry.terraform.io/modules/opsstation/labels/multicloud/latest)

✅ Fully dynamic boot disk + additional disk support (persistent disks, local SSDs, KMS encryption)

✅ Automatic image resolution using google_client_config (project, region, image family fallback)

✅ Advanced network interface configuration — multiple NICs, alias IP ranges, IPv6, public IP, and custom stack types

✅ Integrated service account support with custom OAuth scopes or option to disable it

✅ Optional GPU / accelerator support using dynamic guest_accelerator configuration

✅ Supports Shielded VM & Confidential VM (Secure Boot, vTPM, Integrity Monitoring, AMD SEV-SNP)

✅ Configurable scheduling policies including preemptible, spot VMs, automatic restart, termination actions

✅ Supports VM templates with metadata startup scripts for automated provisioning

✅ Modular and reusable for multiple environments (dev, stage, prod)

---


## ⚙️ Usage Examples

## Example: simple_template

```hcl
  module "simple_template" {
  source               = "opsstation/template-instance/gcp"
  version              = "1.0.1"
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
  enable_public_ip     = true

  metadata = {
    ssh-keys = <<EOF
          dev:ssh-rsa AAAAB3NzaC1yc2EAA/3mwt2y+PDQMU= suresh@suresh
        EOF
  }
}
```

## Example: instance_template (Alias IP Range)

```hcl
  module "instance_template" {
  source            = "opsstation/template-instance/gcp"
  version           = "1.0.1"
  name              = "alias-ip-range"
  environment       = "test"
  instance_template = true
  subnetwork        = module.subnet.subnet_id

  service_account = {
    email  = module.service-account.account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  alias_ip_range = {
    ip_cidr_range         = "/24"
    subnetwork_range_name = module.subnet.subnet_name
  }
}

```
## Example: instance_template (Additional Disks)

```hcl
  module "instance_template" {
  source            = "opsstation/template-instance/gcp"
  version           = "1.0.1"
  name              = "additional-disks"
  environment       = "test"
  subnetwork        = module.subnet.subnet_self_link_public
  instance_template = true

  service_account = null

  additional_disks = [
    {
      disk_name    = "disk-0"
      device_name  = "disk-0"
      disk_size_gb = 10
      disk_type    = "pd-standard"
      auto_delete  = "true"
      boot         = "false"
      disk_labels  = {}
    },
    {
      disk_name    = "disk-1"
      device_name  = "disk-1"
      disk_size_gb = 10
      disk_type    = "pd-standard"
      auto_delete  = "true"
      boot         = "false"
      disk_labels  = { "foo" : "bar" }
    },
    {
      disk_name    = "disk-2"
      device_name  = "disk-2"
      disk_size_gb = 10
      disk_type    = "pd-standard"
      auto_delete  = "true"
      boot         = "false"
      disk_labels  = { "foo" : "bar" }
    }
  ]
}

```

### 🚀 Outputs (GCP Instance Template Module)

| Name                   | Description                                                         |
| ---------------------- | ------------------------------------------------------------------- |
| `id`                   | The unique ID of the instance template resource.                    |
| `name`                 | The name of the instance template.                                  |
| `tags_fingerprint`     | The fingerprint used for optimistic locking when updating tags.     |
| `metadata_fingerprint` | The fingerprint used for optimistic locking when updating metadata. |
| `self_link`            | The self-link URL of the instance template.                         |
| `self_link_unique`     | A unique self-link identifying this specific instance template.     |
| `available_zones`      | A list of all available zones in the selected region.               |


---
### ☁️ Tag Normalization Rules (GCP)

| Cloud | Case      | Allowed Characters | Example                            |
|--------|-----------|------------------|------------------------------------|
| **GCP** | TitleCase | Any              | `Name`, `Environment`, `CostCenter` |