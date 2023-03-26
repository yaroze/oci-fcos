resource "oci_core_vcn" "fcos_vcn" {
    #Required
    compartment_id = oci_identity_compartment.fcos_compartment.id

    cidr_blocks = ["10.60.0.0/16"]
    display_name = "VCN for FCOS"
    #dns_label = "fcos"
    is_ipv6enabled = false
    
    dns_label = "yaroze"
}


resource "oci_core_default_route_table" "fcos_route_table" {
    
    manage_default_resource_id = oci_core_vcn.fcos_vcn.default_route_table_id

    compartment_id = oci_identity_compartment.fcos_compartment.id

    display_name = "FCOS Routing table"
    
    route_rules {
        network_entity_id = oci_core_internet_gateway.fcos_internet_gateway.id

        destination = "0.0.0.0/0"
        description = "Route table for FCOS 0.0.0.0/0"
        
        destination_type = "CIDR_BLOCK"
    }
}

resource "oci_core_default_dhcp_options" "fcod_dhcp_options" {
    manage_default_resource_id = oci_core_vcn.fcos_vcn.default_dhcp_options_id

    compartment_id = oci_identity_compartment.fcos_compartment.id

    options {
        #type = "DomainNameServer"
        #server_type = "VcnLocalPlusInternet"

        server_type = "CustomDnsServer"
        custom_dns_servers = [ "208.67.222.222", "208.67.220.220" ] 
    }

    options {
        type = "SearchDomain"
        search_domain_names = var.search_domain_names
    }

    #Optional
    display_name = "FCOS VCN DHCP Options"
}

resource "oci_core_internet_gateway" "fcos_internet_gateway" {
    
    compartment_id = oci_identity_compartment.fcos_compartment.id
    vcn_id = oci_core_vcn.fcos_vcn.id

    
    enabled = true
    display_name = "FCOS Internet Gateway"
}



resource "oci_core_subnet" "fcos_subnet" {
    #Required
    cidr_block = "10.60.0.0/24"
    compartment_id = oci_identity_compartment.fcos_compartment.id
    vcn_id = oci_core_vcn.fcos_vcn.id
    display_name = "FCOS Subnet"
}