resource "openstack_compute_keypair_v2" "cloud-key" {
    name = "anmol-key"
    public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPtNfCztVmFz5xnekMapou4tiij4QRr9/UAUqNjRvMe cabba@cloudserver"
}

resource "openstack_compute_instance_v2" "public-vm" {
    name = "vm-1"
    image_name = "Ubuntu-22.04"
    flavor_name = "standard.small"
    key_pair = "${openstack_compute_keypair_v2.cloud-key.name}"
    security_groups = [openstack_networking_secgroup_v2.public-vm-secgroup_1.name]

    network {
        name = "project_2011837"
    }

}

resource "openstack_networking_floatingip_v2" "public-vm-public-ip" {
    pool = "public"
}

data "openstack_networking_port_v2" "port_1" {
    fixed_ip = openstack_compute_instance_v2.public-vm.access_ip_v4
}

resource "openstack_networking_floatingip_associate_v2" "public-vm-get-ip" {
    floating_ip = openstack_networking_floatingip_v2.public-vm-public-ip.address
    port_id = data.openstack_networking_port_v2.port_1.id
}

resource "openstack_networking_secgroup_v2" "public-vm-secgroup_1" {
    name = "Public-vm-secgroup_1"
    description = "Secgroup 1 for public vm exercise 7"
}

resource "openstack_networking_secgroup_rule_v2" "http-rule" {
    ethertype = "IPv4"
    direction = "ingress"
    port_range_max = 80
    port_range_min = 80
    protocol = "tcp"
    remote_ip_prefix = "0.0.0.0/0"
    security_group_id = openstack_networking_secgroup_v2.public-vm-secgroup_1.id
}

resource "openstack_networking_secgroup_rule_v2" "https-rule" {
    ethertype = "IPv4"
    direction = "ingress"
    port_range_max = 443
    port_range_min = 443
    protocol = "tcp"
    remote_ip_prefix = "0.0.0.0/0"
    security_group_id = openstack_networking_secgroup_v2.public-vm-secgroup_1.id
}

resource "openstack_networking_secgroup_rule_v2" "ssh-rule" {
    ethertype = "IPv4"
    direction = "ingress"
    port_range_max = 22
    port_range_min = 22
    protocol = "tcp"
    remote_ip_prefix = "0.0.0.0/0"
    security_group_id = openstack_networking_secgroup_v2.public-vm-secgroup_1.id
}

resource "openstack_compute_instance_v2" "private-vm" {
    name = "vm-2"
    image_name = "Ubuntu-22.04"
    flavor_name = "standard.small"
    key_pair = "${openstack_compute_keypair_v2.cloud-key.name}"
    security_groups = [openstack_networking_secgroup_v2.private-vm-secgroup_1.name]

    network {
        name = "project_2011837"
    }

}

resource "openstack_networking_secgroup_v2" "private-vm-secgroup_1" {
    name = "Private-vm-secgroup-1"
    description = "Secgroup for private vm"
}

resource "openstack_networking_secgroup_rule_v2" "priavte-ssh-rule" {
    ethertype = "IPv4"
    direction = "ingress"
    port_range_max = 22
    port_range_min = 22
    protocol = "tcp"
    remote_ip_prefix = "192.168.1.0/24"
    security_group_id = openstack_networking_secgroup_v2.private-vm-secgroup_1.id
}

resource "openstack_networking_secgroup_rule_v2" "mysql-rule" {
    ethertype = "IPv4"
    direction = "ingress"
    port_range_max = 3306
    port_range_min = 3306
    protocol = "tcp"
    remote_ip_prefix = "192.168.1.0/24"
    security_group_id = openstack_networking_secgroup_v2.private-vm-secgroup_1.id
}

