resource "oci_objectstorage_bucket" "test_bucket" {
    #Required
    compartment_id = var.compartment_id
    name = var.bucket_name
    namespace = var.bucket_namespace

    #Optional
    access_type = var.bucket_access_type
    auto_tiering = var.bucket_auto_tiering
    defined_tags = {"application"= "Fedora CoreOS Images"}
#    kms_key_id = oci_kms_key.test_key.id
#    metadata = var.bucket_metadata
#    object_events_enabled = var.bucket_object_events_enabled
    storage_tier = "Standard"
/*    retention_rules {
        display_name = var.retention_rule_display_name
        duration {
            #Required
            time_amount = var.retention_rule_duration_time_amount
            time_unit = var.retention_rule_duration_time_unit
        }
        time_rule_locked = var.retention_rule_time_rule_locked
    }*/
    versioning = "Disabled"
}