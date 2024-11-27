resource "openstack_compute_keypair_v2" "cloud-server-key" {
    name = "my-key"
    public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPtNfCztVmFz5xnekMapou4tiij4QRr9/UAUqNjRvMe cabba@cloudserver"
}


resource "openstack_compute_instance_v2" "public-vm" {
    name = "vm-1"
    image_name = "Ubuntu-20.04"
    flavor_name = "standard.small"
    key_pair = "${openstack_compute_keypair_v2.cloud-server-key.name}"
    security_groups = [openstack_networking_secgroup_v2.secgroup_1.name]

    network {
        name = "project_2011837"
    }
}

resource "openstack_compute_instance_v2" "testvms" {
    name = "vm-${count.index + 2}"
    image_name = "Ubuntu-20.04"
    flavor_name = "standard.small"
    key_pair = "${openstack_compute_keypair_v2.cloud-server-key.name}"
    security_groups = [openstack_networking_secgroup_v2.secgroup_2.name]
    count = 3
    
    network {
        name = "project_2011837"
    }
}

# Deprecated but also works

# resource "openstack_compute_floatingip_v2" "fip_1" {
#     pool = "public"
# }

# resource "openstack_networking_floatingip_associate_v2" "fipas_1" {
#     floating_ip = openstack_networking_floatingip_v2.fip_1.address
#     instance_id = openstack_compute_instance_v2.public-vm.id
# }


# New way is to use openstack_networking

resource "openstack_networking_floatingip_v2" "fip_1" {
    pool = "public"
}

data "openstack_networking_port_v2" "port_1" {
    fixed_ip = openstack_compute_instance_v2.public-vm.access_ip_v4
}

resource "openstack_networking_floatingip_associate_v2" "fipas_1" {
    floating_ip = openstack_networking_floatingip_v2.fip_1.address
    port_id = data.openstack_networking_port_v2.port_1.id
}


resource "openstack_networking_secgroup_v2" "secgroup_1" {
    name        = "secgroup_1"
    description = "My neutron security group"
}

resource "openstack_networking_secgroup_rule_v2" "ssh-rule" {
    ethertype = "IPv4"
    direction = "ingress"
    port_range_min = 22
    port_range_max = 22
    protocol = "tcp"
    remote_ip_prefix = "0.0.0.0/0"
    security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}


resource "openstack_networking_secgroup_rule_v2" "http-rule" {
    ethertype = "IPv4"
    direction = "ingress"
    port_range_min = 80
    port_range_max = 80
    protocol = "tcp"
    remote_ip_prefix = "0.0.0.0/0"
    security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

resource "openstack_networking_secgroup_rule_v2" "project-network" {
    ethertype = "IPv4"
    direction = "ingress"
    port_range_min = 1
    port_range_max = 65535
    protocol = "tcp"
    remote_ip_prefix = "192.168.1.0/24"
    security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

resource "openstack_networking_secgroup_v2" "secgroup_2" {
    name = "secgroup_2"
    description = "Project network"
}

resource "openstack_networking_secgroup_rule_v2" "project_rule" {
    ethertype = "IPv4"
    security_group_id = openstack_networking_secgroup_v2.secgroup_2.id
    direction = "ingress"
    port_range_min = 1
    port_range_max = 65535
    protocol = "tcp"
    remote_ip_prefix = "192.168.1.0/24"
}
