terraform {
  required_version = ">= 1.3.3"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.77.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3"
    }
    ignition = {
      source = "community-terraform-providers/ignition"
      version = "2.5.1"
    }
  }
}
