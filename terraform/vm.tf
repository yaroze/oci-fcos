resource "oci_core_instance" "fcos_instance" {
  count               = var.num_vms
  display_name        = "${var.vm_prefix}${count.index+1 > 9 ? "" : "0"}${count.index+1}"
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.A1.Flex"
  shape_config {
    ocpus = 1
    memory_in_gbs = 1
  }

  metadata = {
    ssh_authorized_keys = "ssh-rsa ***REMOVED***"
  }

  source_details {
    source_type = "image"
    source_id   = oci_core_image.fcosImage.id
  }

  create_vnic_details {
    subnet_id = var.subnet_id
  }

  timeouts {
    create = "30m"
    delete = "30m"
  }

}