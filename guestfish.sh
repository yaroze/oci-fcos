#!/bin/bash
fs_boot_path=$(virt-filesystems -a $1 -l | grep boot | awk -F ' ' '{print $1}')

cd /image
/usr/bin/guestfish <<EOF
echo "Adding qcow2 file"
add $1
echo "Opening qcow2 file..."
run
echo "Mounting..."
mount "$fs_boot_path" /
mkdir /ignition
echo "Uploading ignition..."
copy-in config.ign /ignition/
echo "Done!"
unmount-all 
exit
EOF
