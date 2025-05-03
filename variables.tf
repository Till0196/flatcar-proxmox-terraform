variable "virtual_environment_endpoint" {
  type        = string
  description = "The endpoint for the Proxmox Virtual Environment API (example: https://host:port)"
}

variable "virtual_environment_password" {
  type        = string
  description = "The password for the Proxmox Virtual Environment API"
}

variable "virtual_environment_username" {
  type        = string
  description = "The username and realm for the Proxmox Virtual Environment API (example: root@pam)"
}

variable "virtual_environment_tls_insecure" {
  type        = bool
  description = "Disable TLS verification while connecting to the Proxmox VE API server."
}

variable "virtual_environment_ssh" {
  type = object({
    node = list(object({
      name    = string
      address = string
    }))
    agent    = bool
    username = string
    password = string
  })
  description = "The SSH configuration for the Proxmox Virtual Environment"
}

variable "pve_node_name" {
  type        = string
  description = "The name of the Proxmox VE node"
  default     = "pve"
}

variable "vm_user" {
  type        = string
  description = "The name of the VM"
  default     = "core"
}

variable "vm_password" {
  type        = string
  description = "The password for the VM"
  default     = "password"
}

variable "vm_ip" {
  type        = string
  description = "The IP address of the VM"
}

variable "vm_network_cidr" {
  type        = number
  description = "The CIDR of the VM network"
}

variable "vm_network_gateway" {
  type        = string
  description = "The gateway of the VM network"
}