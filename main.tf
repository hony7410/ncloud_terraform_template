terraform {
  required_providers {
    ncloud = {
      source  = "NaverCloudPlatform/ncloud"
      version = "2.3.0"
    }
  }
  required_version = ">= 0.13"

  # tfstate 저장 object storage bucket 설정
  backend "s3" {
    bucket   = "ncloud-terraform-state"
    key      = "template/terraform.tfstate"
    endpoint = "kr.object.fin-ncloudstorage.com"
    region   = "None"

    access_key = ""
    secret_key = ""

    force_path_style            = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}

# variable
provider "ncloud" {
  access_key  = var.access_key
  secret_key  = var.secret_key
  region      = var.region
  site        = var.site
  support_vpc = var.support_vpc
}

#vpc ip cidr
resource "ncloud_vpc" "prod" {
  name            = "prod"
  ipv4_cidr_block = "192.168.0.0/16"
}

#ncloud server login key
resource "ncloud_login_key" "prod" {
  key_name = "prod"
}