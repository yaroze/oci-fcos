
# oci-fcos

This project fetches a FCOS qcow2 image and injects an ignition file generated by comes from butane.

The Ansible playbook relies on Podman, so it might not work properly with Docker. 
If you use Docker, it's better to run the "script.sh" instead of the Ansible playbook.

After preparing the qcow2 image, it creates a bucket on Oracle Cloud, uploads the image there and spins a VM with that image after deploying it as a custom image.

This is a nice automation to run on Oracle's OCI Developer VM's.

### TODO:
```
- [x] Create terraform to upload this to OCI
- [x] Create Ansible to run the image related stuff
- [ ] Deploy with GitHub Actions
- [ ] Do some proper documentation...
```



