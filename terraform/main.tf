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

resource "oci_core_instance" "example" {
  availability_domain = var.availability_domain
  compartment_id = var.compartment_id
  display_name = "example-instance"
  shape = "VM.Standard.A1.Flex"

  shape_config {
    ocpus = 1
    memory_in_gbs = 1
  }

  metadata = {
    ssh_authorized_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8lEvWJgdjX9iufMsN1X2h4PzuoWcvEj9u1yrGikqESqOW6AERkjwFU7mjCKG0lbrzwfZbGE0BZ6Y124FP3hgjCb6h4M3lTH9AYsWHDXzkn45+ys1vDg88iP14AqaOiDOGqigUsPezi7jBzzMH0q+1gEh2AbGyasCHkkiOmlJw+qYl2Qd3UOijcrVQtLRhgLXzU8bo4TZYUAY0J0txAIqrukL/oKKbl7pIokG1o4nIACVPt0oOEJeS/fVr8rX67xslENvbzAlGNjEzSlMT+Cu2i7DsiDviN7gNm0ZXM+ural9zxzrLJu4RX8SJoh85IYvV6iHb6a5RBYy7x5X+G/3j1Ap5Odu2PUCiNDKsgTsp/6/JY/H4RYv1gqKpn7Mu36cl3oYaXGuDwZO4Ba92x/Ythn4U6krvFzuORDs8gqAgyzPg/4MbL+9KMTj4Rg8nTbOVhrzKrOH9PAU3tr/3VPate5AaMRoUkx9TmOA5uwiCbFNftaNNwwgMIKnFrHeScIM= pedro@MacBook-Pro-de-Pedro.local"
  }

  source_details {
    source_type = "image"
    source_id = var.image_id
  }

  create_vnic_details {
    subnet_id = var.subnet_id
  }

  timeouts {
    create = "30m"
    delete = "30m"
  }

  launch_options {
    firmware = "UEFI_64"
    network_type = "PARAVIRTUALIZED"
  }
}

