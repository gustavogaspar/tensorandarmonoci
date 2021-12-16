variable "tenancy_ocid" {  
}
variable "compartment_id" {  
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





