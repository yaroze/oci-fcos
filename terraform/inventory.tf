resource "local_file" "ansible_inventory" {
 content = templatefile("inventory.tmpl",
    {
     instance_ip   = oci_core_instance.fcos_instance.public_ip
     instance_name = oci_core_instance.fcos_instance.display_name

    }
  )
  filename = "inventory.txt"
}