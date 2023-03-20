
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
}
