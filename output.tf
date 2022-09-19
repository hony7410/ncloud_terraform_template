#ansible inventory 형태로 output 출력을 위한 세팅
data "ncloud_root_password" "prod-rootpwd" {
  for_each = var.prod_server

  server_instance_no = ncloud_server.prod-server[each.key].id
  private_key        = ncloud_login_key.prod.private_key
}

data "template_file" "prod-servers" {
  for_each = var.prod_server

  template = file("${path.module}/output/inventory.tpl")

  vars = {
    hostname  = "${ncloud_server.prod-server[each.key].name}"
    privateip = "${ncloud_server.prod-server[each.key].network_interface[0].private_ip}"
    rootpwd   = "${data.ncloud_root_password.prod-rootpwd[each.key].root_password}"
  }
}

resource "null_resource" "render_template" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command     = "cat > output/inventory << 'EOF'\n${join("\n", [for idx in data.template_file.prod-servers : idx.rendered])}\nEOF"
    interpreter = ["bash", "-c"]
  }
}
