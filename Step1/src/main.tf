// Variables

variable "tenancy_ocid" {  
}
variable "compartment_id" {  
}


// Datasources

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "image_arm" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

data "oci_core_images" "image_x86" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.E3.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}







//Network

resource "oci_core_vcn" "arm_vcn" {
    #Required
    compartment_id = var.compartment_id
    cidr_block = "10.0.0.0/24"
    display_name = "vcn_arm"

}

resource "oci_core_internet_gateway" "arm_internet_gateway" {
    #Required
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.arm_vcn.id
}

resource "oci_core_route_table" "arm_route_table" {
    #Required
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.arm_vcn.id

    route_rules {
        #Required
        network_entity_id = oci_core_internet_gateway.arm_internet_gateway.id
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
    }
}

resource "oci_core_security_list" "arm_sl" {
  compartment_id = var.compartment_id
  display_name = "arm_sl"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
  }
  freeform_tags = {
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  ingress_security_rules {
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    icmp_options {
      code = "-1"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  vcn_id = oci_core_vcn.arm_vcn.id
}

resource "oci_core_subnet" "arm_subnet" {
    #Required
    cidr_block = "10.0.0.0/24"
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.arm_vcn.id
    display_name = "subnet_arm"
    route_table_id = oci_core_route_table.arm_route_table.id
    security_list_ids = [oci_core_security_list.arm_sl.id]

    depends_on = [oci_core_vcn.arm_vcn]
}


//ARM Compute

resource "oci_core_instance" "arm_instance" {
    #Required
    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
    compartment_id = var.compartment_id
    shape = "VM.Standard.A1.Flex"
    create_vnic_details {
        assign_public_ip = true
        subnet_id = oci_core_subnet.arm_subnet.id
    }
    display_name = "ARM-Instance"
    metadata = { "ssh_authorized_keys" : "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFzE3PbRsCb37lTiD6tCu2a/0Xj4yYmjExbg6xXD/Yjh9JN3D9FIhDHXFznixaRN3ni7HD37OqHEKBr06z2TyXigrZlnVP4i2LXXy0kRTJRyN6Zqc+VN1pz1GH+9pbWmd1tLfbHQy2Bp4hyRJO7qCP2QN4DUSMssxeASENZ61di3t9CiUExc061vKtdq+CSEMrR3619pvfDEF0wJ3n2we+pG/dL0oDWgxGR3m2pRYYHWQJr0HAFJ9dFyKO1zmNKJxDgjIU2jjcujBCzLpGyzfnCzt4loN8hVPTHpne0cAjJC/upZOOxUaOaGcmesUC6g007Y4RqWkE0mwZPHwKl4vN ssh-key-2021-06-09"}
    shape_config {
        memory_in_gbs = 8
        ocpus = 2
    }
    source_details {
        source_id = lookup(data.oci_core_images.image_arm.images[0], "id")
        source_type = "image"
    }
    preserve_boot_volume = false
}

//ARM Compute

resource "oci_core_instance" "x86_instance" {
    #Required
    availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name")
    compartment_id = var.compartment_id
    shape = "VM.Standard.E3.Flex"
    create_vnic_details {
        assign_public_ip = true
        subnet_id = oci_core_subnet.arm_subnet.id
    }
    display_name = "x86-Instance"
    metadata = { "ssh_authorized_keys" : "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFzE3PbRsCb37lTiD6tCu2a/0Xj4yYmjExbg6xXD/Yjh9JN3D9FIhDHXFznixaRN3ni7HD37OqHEKBr06z2TyXigrZlnVP4i2LXXy0kRTJRyN6Zqc+VN1pz1GH+9pbWmd1tLfbHQy2Bp4hyRJO7qCP2QN4DUSMssxeASENZ61di3t9CiUExc061vKtdq+CSEMrR3619pvfDEF0wJ3n2we+pG/dL0oDWgxGR3m2pRYYHWQJr0HAFJ9dFyKO1zmNKJxDgjIU2jjcujBCzLpGyzfnCzt4loN8hVPTHpne0cAjJC/upZOOxUaOaGcmesUC6g007Y4RqWkE0mwZPHwKl4vN ssh-key-2021-06-09"}
    shape_config {
        memory_in_gbs = 8
        ocpus = 2
    }
    source_details {
        source_id = lookup(data.oci_core_images.image_x86.images[0], "id")
        source_type = "image"
    }
    preserve_boot_volume = false
}
