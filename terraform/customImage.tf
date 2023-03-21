
resource "oci_core_image" "fcosImage" {
    # Required
    compartment_id = var.compartment_id

    image_source_details {
        # Required
        source_type = "objectStorageTuple"
        namespace_name = var.bucket_namespace
        bucket_name = oci_objectstorage_bucket.newBucket.name
        object_name = oci_objectstorage_object.exampleObject.object
        source_image_type = "QCOW2"

        # Optional
        operating_system = "Fedora CoreOS"
        operating_system_version = "37"
    }

    # Optional
    display_name = "Fedora CoreOS Image"
    launch_mode = "PARAVIRTUALIZED"

}

resource "oci_core_shape_management" "compatible_shape" {
  compartment_id = var.compartment_id
  image_id       = oci_core_image.fcosImage.id
  shape_name     = "VM.Standard.A1.Flex"
}

# This one was a pain to code!
resource "oci_core_compute_image_capability_schema" "fcosImage" {
  compartment_id                                      = var.compartment_id
  display_name                                        = "displayName"
  image_id                                            = oci_core_image.fcosImage.id
  compute_global_image_capability_schema_version_name = data.oci_core_compute_global_image_capability_schemas_versions.fcosImage.compute_global_image_capability_schema_versions[0].name

  schema_data = {
    "Compute.Firmware" =       "{\"descriptorType\": \"enumstring\",\"source\": \"IMAGE\",\"defaultValue\": \"UEFI_64\",         \"values\": [\"BIOS\",\"UEFI_64\"]}"
}
}

data "oci_core_compute_global_image_capability_schemas_version" "fcosImage" {
  compute_global_image_capability_schema_id           = data.oci_core_compute_global_image_capability_schema.fcosImage.id
  compute_global_image_capability_schema_version_name = data.oci_core_compute_global_image_capability_schemas_versions.fcosImage.compute_global_image_capability_schema_versions[0].name
}

data "oci_core_compute_image_capability_schema" "fcosImage" {
  compute_image_capability_schema_id = oci_core_compute_image_capability_schema.fcosImage.id
  is_merge_enabled                   = "true"
}

data "oci_core_compute_global_image_capability_schemas_versions" "fcosImage" {
  compute_global_image_capability_schema_id = data.oci_core_compute_global_image_capability_schema.fcosImage.id
}

data "oci_core_compute_global_image_capability_schema" "fcosImage" {
  compute_global_image_capability_schema_id = data.oci_core_compute_global_image_capability_schemas.fcosImage.compute_global_image_capability_schemas[0].id
}

data "oci_core_compute_global_image_capability_schemas" "fcosImage" {
}