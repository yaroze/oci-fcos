resource "local_file" "ansible_inventory" {
  filename = "inventory.yml"
  content  = replace(yamlencode({
    all = {
      hosts = {
        for host in oci_core_instance.fcos_instance : host.display_name => {
          ansible_host = host.public_ip
          ansible_ssh_extra_args = "-o StrictHostKeyChecking=no"
          ansible_user = "core"
        }
      }
    }
  }), "\"", "")
}