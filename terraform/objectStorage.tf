resource "oci_objectstorage_bucket" "newBucket" {
    #Required
    compartment_id = var.compartment_id
    name = var.bucket_name
    namespace = var.bucket_namespace

   # defined_tags = {"application"= "Fedora CoreOS Images"}
    storage_tier = "Standard"


    versioning = "Disabled"
}

resource "oci_objectstorage_object" "exampleObject" {
    # Required
    bucket = oci_objectstorage_bucket.newBucket.name
    namespace = var.bucket_namespace
    object = "fcos.qcow2"
    source = "${path.module}/../fcos.qcow2"

    # Optional
    content_type = "application/octet-stream"
}

