# Nat Gateway
resource "ncloud_nat_gateway" "prod-natgateway" {
  vpc_no = ncloud_vpc.prod.id
  zone   = "FKR-1"

  name = "prod-natgateway"
}

# ACL 
resource "ncloud_network_acl" "prod-acl" {

  for_each = var.prod_subnets

  vpc_no = ncloud_vpc.prod.id
  name   = each.key

}

# Subnet 생성
resource "ncloud_subnet" "prod-subnet" {

  for_each = var.prod_subnets

  vpc_no         = ncloud_vpc.prod.id
  network_acl_no = ncloud_network_acl.prod-acl[each.key].id
  zone           = each.value.zone

  subnet      = each.value.cidr
  subnet_type = each.value.subnet_type
  name        = each.value.subnet_name
  usage_type  = each.value.usage_type
}

# Route Table 생성
resource "ncloud_route_table" "prod-route-table" {

  for_each = var.prod_subnets

  vpc_no                = ncloud_vpc.prod.id
  supported_subnet_type = each.value.subnet_type
  name                  = each.value.subnet_name
}

#public ip service
resource "ncloud_public_ip" "public-ip" {
  for_each = { for key, val in var.prod_server :
  key => val if val.public_ip }

  server_instance_no = ncloud_server.prod-server[each.key].id
}

resource "ncloud_route_table_association" "prod-route-table-association" {

  for_each = var.prod_subnets

  route_table_no = ncloud_route_table.prod-route-table[each.key].id
  subnet_no      = ncloud_subnet.prod-subnet[each.key].id
}

resource "ncloud_route" "natgw_routing" {
  for_each = { for key, val in var.prod_subnets :
  key => val if val.subnet_type == "PRIVATE" && val.zone == "FKR-1" }

  route_table_no         = ncloud_route_table.prod-route-table[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  target_type            = "NATGW"
  target_name            = ncloud_nat_gateway.prod-natgateway.name
  target_no              = ncloud_nat_gateway.prod-natgateway.id
}
