variable "tenancy_ocid" {
  type = string
}

variable "user_ocid" {
  type = string
}

variable "fingerprint" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "region" {
  type = string
}

variable "availability_domain" {
  type = string
}

variable "compartment_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "image_id" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "bucket_namespace" {
  type = string
}

variable "num_vms" {
  type = string
  default = "1"
}

variable "vm_prefix" {
  type = string
  default = "vm-"
}
