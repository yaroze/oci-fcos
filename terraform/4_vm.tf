resource "oci_core_instance" "fcos_instance" {
  count               = var.num_vms
  display_name        = "${var.vm_prefix}${count.index+1 > 9 ? "" : "0"}${count.index+1}"
  availability_domain = var.availability_domain
  compartment_id      = oci_identity_compartment.fcos_compartment.id
  shape               = "VM.Standard.A1.Flex"
  shape_config {
    ocpus = 1
    memory_in_gbs = 1
  }

  metadata = {
    ssh_authorized_keys = "***REMOVED***"
  }

  source_details {
    source_type = "image"
    source_id   = oci_core_image.fcosImage.id
  }

  create_vnic_details {
    subnet_id = oci_core_subnet.fcos_subnet.id
  }

  timeouts {
    create = "30m"
    delete = "30m"
  }

}
