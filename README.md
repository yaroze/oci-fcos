# oci-fcos

This project fetches a FCOS qcow2 image and injects an ignition file that comes from butane.

It relies on Podman, so it might not work with Docker.

After preparing the qcow2 image, it creates a bucket on Oracle Cloud, uploads the image there and spins a VM with that image.


### TODO:
Create terraform to upload this to OCI.

Create a GitHub Actions build.

Do some proper documentation...