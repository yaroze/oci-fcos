resource "oci_identity_compartment" "fcos_compartment" {
    #Required
    compartment_id = var.tenancy_ocid
    description = "Compartment for Fedora CoreOS stuff"
    name = "FCOSCompartment"

    #Optional
    freeform_tags = {"Use"= "Fedora CoreOS"}
}