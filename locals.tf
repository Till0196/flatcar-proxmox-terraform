locals {
    github_ids = [
      "till0196"
    ]

    pve_datastore_name = "local"

    os_image_file_name = "flatcar_production_proxmoxve_image.img"
    os_image_url       = "https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_proxmoxve_image.img"

    vm_name = "flatcar-container-linux"
    vm_id = 900
    vm_on_boot  = false
    vm_bridge_name = "vmbr0"
    vm_bridge_mtu  = 0
    vm_dns_servers = ["1.1.1.1", "8.8.8.8"]

    os_datastore_lvm_name = "guest-os-lvm"
}