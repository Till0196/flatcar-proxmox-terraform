# Proxmox VE
########################################################################
# Proxmox VE API details and VM hosting configuration
# API token guide: https://registry.terraform.io/providers/bpg/proxmox/2.9.14/docs

virtual_environment_endpoint     = "https://192.168.0.2:8006"
virtual_environment_username     = "root@pam"
virtual_environment_password     = "password"
virtual_environment_tls_insecure = true
virtual_environment_ssh = {
  node = [
    {
      name    = "pve1"
      address = "192.168.0.2"
    },
    {
      name    = "pve2"
      address = "192.168.0.3"
    }
  ]
  agent    = false
  username = "root"
  password = "password"
}

vm_user = "core"
vm_password = "password"

pve_node_name = "pve1"

vm_ip = "192.168.0.10"
vm_network_cidr = 24
vm_network_gateway = "192.168.0.1"