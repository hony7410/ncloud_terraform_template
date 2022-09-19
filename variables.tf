variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "region" {
  default = "FKR"
}

variable "site" {
  default = "fin"
}

variable "support_vpc" {
  type    = bool
  default = true
}

# ACG definition 
variable "prod_acg" {
  type = set(string)
  default = [
    "web-acg",
    "was-acg",
  ]
}

# Subnet definition
variable "prod_subnets" {
  type = map(object({
    subnet_name = string
    cidr        = string
    zone        = string
    subnet_type = string
    usage_type  = string
  }))

  default = {
    web = { subnet_name = "web", cidr = "192.168.1.0/24", zone = "FKR-1", subnet_type = "PUBLIC", usage_type = "GEN" },
    was = { subnet_name = "was", cidr = "192.168.10.0/24", zone = "FKR-1", subnet_type = "PRIVATE", usage_type = "GEN" },
  }
}

# Server definition 
variable "prod_server" {
  type = map(object({
    nic_ip1                = string
    spec                   = string
    acg                    = string
    subnet_name            = string
    add_storage            = string
    server_image           = string
    member_server_image_no = string
    public_ip              = bool
  }))

  default = {
    web01 = { nic_ip1 = "192.168.1.11", spec = "tiny", acg = "web-acg", subnet_name = "web", add_storage = "0", server_image = "ubuntu18.04", member_server_image_no = null, public_ip = true },
    web02 = { nic_ip1 = "192.168.1.12", spec = "tiny", acg = "web-acg", subnet_name = "web", add_storage = "0", server_image = "ubuntu18.04", member_server_image_no = null, public_ip = true},
    was01 = { nic_ip1 = "192.168.10.11", spec = "small", acg = "was-acg", subnet_name = "was", add_storage = "0", server_image = "ubuntu18.04", member_server_image_no = null, public_ip = false },
    was02 = { nic_ip1 = "192.168.10.12", spec = "small", acg = "was-acg", subnet_name = "was", add_storage = "0", server_image = "ubuntu18.04", member_server_image_no = null, public_ip = false },
  }
}

variable "server_images" {
  type = map(any)
  default = {
    "centos7.8"   = "SW.VSVR.OS.LNX64.CNTOS.0708.B050"     # CentOS 7.8 (64-bit)
    "redhat7.6"   = "SW.VSVR.OS.LNX64.RHEL.0706.B050.H001" # Red Hat 7.6 (64-bit)
    "redhat8.2"   = "SW.VSVR.OS.LNX64.RHEL.0802.B050.H001" # Red Hat 8.2 (64-bit)
    "ubuntu18.04" = "SW.VSVR.OS.LNX64.UBNTU.SVR1804.B050"  # Ubuntu Server 18.04 (64-bit)
  }
}

variable "server_specs" {
  type = map(any)
  default = {
    "tiny"    = "SVR.VSVR.STAND.C002.M004.NET.HDD.B050.G001" # vCPU 2EA, Memory 4GB, Disk 50GB
    "small"   = "SVR.VSVR.STAND.C004.M008.NET.HDD.B050.G001" # vCPU 4EA, Memory 8GB, Disk 50GB
    "medium"  = "SVR.VSVR.STAND.C008.M016.NET.HDD.B050.G001" # vCPU 8EA, Memory 16GB, Disk 50GB
    "large"   = "SVR.VSVR.HIMEM.C016.M128.NET.SSD.B050.G001" # vCPU 16EA, Memory 128GB, [SSD]Disk 50GB
  }
}
