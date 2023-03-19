#!/bin/bash
/usr/bin/guestfish <<EOF
echo "Adding qcow2 file"
add fcos.qcow2
echo "Opening qcow2 file..."
run
echo "Mounting..."
mount /dev/sda3 /
echo "Uploading ignition..."
upload ignition.ign /ignition.firstboot
echo "Done!"
EOF