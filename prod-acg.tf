
# variable 의 acg 생성
resource "ncloud_access_control_group" "prod-acg" {
  for_each = var.prod_acg

  vpc_no = ncloud_vpc.prod.id
  name   = each.value
}

# webserver 용 ACG 룰 적용
resource "ncloud_access_control_group_rule" "web-acg" {
  access_control_group_no = ncloud_access_control_group.prod-acg["web-acg"].id
  
  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "80"
    description = "HTTP 서비스"
  }
  inbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "443"
    description = "HTTPS 서비스"
  }
  outbound {
    protocol    = "TCP"
    ip_block    = "0.0.0.0/0"
    port_range  = "1-65535"
    description = "Outbound 오픈"
  }
}
# wasserver 용 ACG 룰 적용
resource "ncloud_access_control_group_rule" "was-acg" {
  access_control_group_no = ncloud_access_control_group.prod-acg["was-acg"].id

  inbound {
    protocol                       = "TCP"
    port_range                     = "8443"
    description                    = "WAS 서비스"
    source_access_control_group_no = ncloud_access_control_group.prod-acg["web-acg"].id
  }
}
