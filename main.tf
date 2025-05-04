resource "proxmox_virtual_environment_download_file" "os_image" {
  node_name    = var.pve_node_name

  content_type = "iso"
  datastore_id = local.pve_datastore_name
  url          = local.os_image_url
  file_name    = local.os_image_file_name
  overwrite_unmanaged = true
}

data "http" "gh_key" {
  for_each = { for id in local.github_ids : id => id }
  url      = "https://github.com/${each.value}.keys"
}

data "ignition_user" "user" {
    name = var.vm_user
    password_hash = "${bcrypt(var.vm_password)}"
    ssh_authorized_keys = flatten([
        for id, key in data.http.gh_key : [
            for line in split("\n", chomp(key.body)) : 
                line if trimspace(line) != ""
        ]
    ])
}

data "ignition_file" "hostname" {
    path = "/etc/hostname"
    mode = 644
    contents {
        source = "data:text/plain;charset=utf-8;base64,${base64encode("flatcar-test")}"
    }
}

data "ignition_systemd_unit" "nginx" {
    name = "nginx.service"
    content = join("\n", [
        "[Unit]",
        "Description=NGINX example",
        "After=docker.service",
        "Requires=docker.service",
        "",
        "[Service]",
        "TimeoutStartSec=0",
        "ExecStartPre=-/usr/bin/docker rm --force nginx1",
        "ExecStart=/usr/bin/docker run --name nginx1 --pull always --net host docker.io/nginx:1",
        "ExecStop=/usr/bin/docker stop nginx1",
        "Restart=always",
        "RestartSec=5s",
        "",
        "[Install]",
        "WantedBy=multi-user.target"
    ])
}

data "ignition_file" "docker-compose" {
    path = "/opt/extensions/docker-compose/docker-compose-2.35.1-x86-64.raw"
    contents {
        source = "https://github.com/flatcar/sysext-bakery/releases/download/docker-compose-2.35.1/docker-compose-2.35.1-x86-64.raw"
    }
}

data "ignition_file" "docker-compose-conf" {
    path = "/etc/sysupdate.docker-compose.d/docker-compose.conf"
    contents {
        source = "https://github.com/flatcar/sysext-bakery/releases/download/docker-compose-2.35.1/docker-compose.conf"
    }
}

data "ignition_link" "docker-compose-symlink" {
    path = "/etc/extensions/docker-compose.raw"
    target = "/opt/extensions/docker-compose/docker-compose-2.35.1-x86-64.raw"
    hard = false
}

data "ignition_config" "ignition" {
  users = [
    data.ignition_user.user.rendered,
  ]
  files = [
    data.ignition_file.hostname.rendered,
    data.ignition_file.docker-compose.rendered,
    data.ignition_file.docker-compose-conf.rendered
  ]
  links = [
    data.ignition_link.docker-compose-symlink.rendered
  ]
  systemd = [
    data.ignition_systemd_unit.nginx.rendered,
  ]
}

resource "proxmox_virtual_environment_file" "ignition" {
  content_type = "snippets"
  datastore_id = local.pve_datastore_name
  node_name    = var.pve_node_name

  source_raw {
    data = data.ignition_config.ignition.rendered
    file_name = "ignition.yaml"
  }

  lifecycle {
    ignore_changes = [ source_raw ]
  }
}

resource "proxmox_virtual_environment_vm" "create_vm" {
  node_name   = var.pve_node_name

  name        = local.vm_name
  vm_id       = local.vm_id
  description = "flatcar container linux (Managed by OpenTofu)"
  tags        =  ["opentofu-managed"]

  on_boot     = local.vm_on_boot

  machine = "q35"
  bios    = "ovmf"

  cpu {
    cores     = 2
    type      = "x86-64-v2-AES"
  }

  memory {
    dedicated = 1024
  }

  agent {
    enabled = true
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 6.X.
  }

  scsi_hardware = "virtio-scsi-pci"

  network_device {
    bridge = local.vm_bridge_name
    model  = "virtio"
    mtu    = local.vm_bridge_mtu
  }

  initialization {
    interface = "scsi1"

    dns {
      servers = local.vm_dns_servers
    }

    ip_config {
      ipv4 {
        address = "${var.vm_ip}/${var.vm_network_cidr}"
        gateway = var.vm_network_gateway
      }
    }

    datastore_id      = local.os_datastore_lvm_name
    user_data_file_id = proxmox_virtual_environment_file.ignition.id
  }

  efi_disk {
    datastore_id = local.os_datastore_lvm_name
    file_format  = "raw"
    type         = "4m"
  }

  disk {
    datastore_id = local.os_datastore_lvm_name
    file_id      = proxmox_virtual_environment_download_file.os_image.id
    file_format  = "raw"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 10
  }
  
}