[![Docker-aarch64](https://github.com/yaroze/oci-fcos/actions/workflows/docker-aarch64.yml/badge.svg?branch=gh_actions)](https://github.com/yaroze/oci-fcos/actions/workflows/docker-aarch64.yml)
[![Docker-amd64](https://github.com/yaroze/oci-fcos/actions/workflows/docker-amd64.yml/badge.svg?branch=gh_actions)](https://github.com/yaroze/oci-fcos/actions/workflows/docker-amd64.yml)

# oci-fcos

This project fetches a FCOS qcow2 image and injects an ignition file generated by butane.

The Ansible playbook relies on Podman, so it might not work properly with Docker. 
If you use Docker, it's better to run the "script.sh" instead of the Ansible playbook.

After preparing the qcow2 image, it creates a bucket on Oracle Cloud, uploads the image there and spins a VM with that image after deploying it as a custom image.

This is a nice automation to run on Oracle's OCI Developer VM's.

## How to use

This project relies on an Ansible role and Terraform.
To run the full pipeline, run Ansible with the following command line:

`ansible-playbook -i oci-fcos/inventory.yml role.yml`

The Ansible role:

- Downloads the latest qemu image of Fedora CoreOS for aarch64 (this can be changed)
- Creates an [Ignition file](https://github.com/coreos/ignition) out of a given [Butane](https://github.com/coreos/butane)
- Creates a Podman container with libguestfs, needed to modify the qcow2 image
- Embeds the ignition file on the qcow2 image
- Launches Terraform:
	- Creates a Bucket on Oracle Cloud
	- Uploads the patched qcow2 image to the recently created bucket
	- Creates a Custom Image out of the uploaded image
	- Modifies the Image Capabilities to boot with UEFI_64 instead of BIOS
	- Creates a Virtual Machine with the given qcow2 image and exposes it to the public

⚠️ It is assumed the butane file is edited with the desired public key!



## Requirements

This project was developed on:
```
$ terraform version
Terraform v1.4.2
on linux_arm64
+ provider registry.terraform.io/hashicorp/local v2.4.0
+ provider registry.terraform.io/oracle/oci v4.112.0
```

and

```
$ ansible --version
ansible 2.9.27
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['XXX']
  ansible python module location = XXX
  executable location = XXX
  python version = 3.6.8 (default, Nov 10 2021, 06:50:25) [GCC 8.5.0 20210514 (Red Hat 8.5.0-3.0.2)]
```

Additionally, the following collection should be installed:
`containers.podman.podman_container`

Deploy it with:
`ansible-galaxy collection install containers.podman`

I developed it on an Oracle Linux 8.5 VM, so it should work fine on Red Hat or Fedora, or a Debian based distro (although some changes might be necessary).

### TODO:

- [x] Create terraform to upload this to OCI
- [x] Create Ansible to run the image related stuff
- [ ] Deploy with GitHub Actions
- [ ] Do some proper documentation (requirements, etc)...



