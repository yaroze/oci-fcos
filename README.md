[![Docker-aarch64](https://github.com/yaroze/oci-fcos/actions/workflows/docker-aarch64.yml/badge.svg?branch=main)](https://github.com/yaroze/oci-fcos/actions/workflows/docker-aarch64.yml)
[![Docker-amd64](https://github.com/yaroze/oci-fcos/actions/workflows/docker-amd64.yml/badge.svg?branch=main)](https://github.com/yaroze/oci-fcos/actions/workflows/docker-amd64.yml)

# oci-fcos

- [oci-fcos](#oci-fcos)
  - [How to use](#how-to-use)
  - [Requirements](#requirements)
  - [Usage](#usage)
  - [FAQ](#faq)
    - [Why are you doing this?](#why-are-you-doing-this)
    - [Why Oracle Cloud? Did you turn to the dark side of the force?](#why-oracle-cloud-did-you-turn-to-the-dark-side-of-the-force)
    - [Don't you have anything better to do?](#dont-you-have-anything-better-to-do)
    - [You should be ashamed! Your code sucks! Why are you making this public?](#you-should-be-ashamed-your-code-sucks-why-are-you-making-this-public)
  - [TODO](#todo)

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

This project was developed on Oracle Linux 8.5 and:

```
$ podman -v
podman version 3.4.2
```

```
$ oci -v
3.9.0
```
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

I developed it on an Oracle Linux 8.5 VM, so it should work fine on Red Hat or maybe even Fedora. I don't know about Debian and derivatives.

## Usage

The code is constantly changing and new ideas pop up every now and then. So the usage might change every now and then.

One of the ideas is to containerize everything, including Terraform, Ansible and OCI client, so that it gets (much) easier to use and distro-agnostic, but for now, just install the prerequisites, configure OCI client, run the Ansible playbook and it will do everything it needs. If it doesn't, please open an issue.



## FAQ


### Why are you doing this?
First, because I want to.
Also, OCI doesn't seem to support ignition, so I had to find an automated way to customize my Fedora Core OS images in order to use them in OCI.


### Why Oracle Cloud? Did you turn to the dark side of the force?
Second question first:  
No, absolutely not.  


First question:  
Believe it or not, OCI has a lot of *Always Free* resources such as VMs, Object and Block storage, and Oracle databases. If you're not an Oracle person, you can always spin an Ampere VM with 4vCPU and 24GB of RAM for free and 10TB of in/egress also for free.

What other cloud provides does this [(**forever**)](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)?

Also, their block and object storage is quite cheap compared to AWS's. Take a look at [this](https://www.oracle.com/cloud/economics/).

So, first reason is cost. I don't want to spend a shitload of money to support my personal projects, that won't be profitable for the time being. Also, my laptop runs on an ARM processor, so if I can use the same architecture on both sides, the better :)

Second reason is, I used to be an Oracle consultant. I did a ton of PL/SQL coding, Database Administration and performance tunning. I'd love to have a RAC at home, just to play with it, but you know... costs...  
So if I have the opportunity to have a small DBaaS, at least I can take that as an opportunity to learn APEX or have 20GB of storage for free.  

I can also run an XE on a VM for cheap if I spin a burstable instance...

### Don't you have anything better to do?
Of course, I have many better things I could be doing, but the truth is you'll loose the momentum if you stop.  
The world is transitioning to public clouds and I'm taking this as an opportunity to improve my Terraform and Ansible skills as well as containerization.

### You should be ashamed! Your code sucks! Why are you making this public?
I'm not :). Yup, my code might suck.

I always say I'm here to learn and want to learn from people who know more than I. So please fork the repo, change the code and create a pull request. I'm totally open to suggestions :)

Now, it's my turn: Why are you here on GitHub?


## TODO

- [x] Create terraform to upload this to OCI
- [x] Create Ansible to run the image related stuff
- [ ] Deploy with GitHub Actions
- [ ] Do some proper documentation (requirements, etc)...
- [ ] Containerize!!!