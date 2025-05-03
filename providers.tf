provider "proxmox" {
  endpoint = var.virtual_environment_endpoint
  username = var.virtual_environment_username
  password = var.virtual_environment_password
  insecure = var.virtual_environment_tls_insecure
  ssh {
    dynamic "node" {
      for_each = var.virtual_environment_ssh.node
      content {
        name    = node.value.name
        address = node.value.address
      }
    }
    agent    = var.virtual_environment_ssh.agent
    username = var.virtual_environment_ssh.username
    password = var.virtual_environment_ssh.password
  }
}
