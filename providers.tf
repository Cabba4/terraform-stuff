# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  tenant_name = "anmolaro"
  auth_url    = "https://pouta.csc.fi:5001/v3"
  region      = "regionOne"
}
