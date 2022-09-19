resource "ncloud_network_interface" "prod-interface" {
  for_each = var.prod_server

  name       = each.key
  subnet_no  = ncloud_subnet.prod-subnet[each.value.subnet_name].id
  private_ip = each.value.nic_ip1

  access_control_groups = [
    ncloud_access_control_group.prod-acg["${each.value.acg}"].id
  ]
}

resource "ncloud_server" "prod-server" {
  for_each = var.prod_server

  subnet_no      = ncloud_subnet.prod-subnet["${each.value.subnet_name}"].id
  login_key_name = ncloud_login_key.prod.key_name

  name = each.key
  server_image_product_code = (each.value.server_image == null ? null : var.server_images["${each.value.server_image}"])
  server_product_code       = var.server_specs["${each.value.spec}"]
  member_server_image_no    = try(each.value.member_server_image_no, null)

  network_interface {
    network_interface_no = ncloud_network_interface.prod-interface[each.key].id
    order                = 0
  }
}

resource "ncloud_block_storage" "prod-server-storage" {

  for_each = { for key, val in var.prod_server :
  key => val if val.add_storage != "0" }

  server_instance_no = ncloud_server.prod-server[each.key].id
  name               = "${each.key}-storage"
  size               = each.value.add_storage
  disk_detail_type   = "SSD"
}
