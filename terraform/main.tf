terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
    }
  }
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  fingerprint = var.fingerprint
  private_key_path = var.private_key_path
  region = var.region
}

resource "oci_core_instance" "fcos_instance" {
  availability_domain = var.availability_domain
  compartment_id = var.compartment_id
  display_name = "example-instance"
  shape = "VM.Standard.A1.Flex"

  shape_config {
    ocpus = 1
    memory_in_gbs = 1
  }

  metadata = {
    ssh_authorized_keys = "ssh-rsa ***REMOVED***"
  }

  source_details {
    source_type = "image"
    #source_id = var.image_id
    source_id = oci_core_image.fcosImage.id
  }

  create_vnic_details {
    subnet_id = var.subnet_id
  }

  timeouts {
    create = "30m"
    delete = "30m"
  }

}