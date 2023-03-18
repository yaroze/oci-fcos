#!/bin/bash
echo "Generating ignition file out of butane..."
docker  run -i --rm quay.io/coreos/butane:release --pretty --strict < butane.bu > ignition.ign

echo "Downloading latest FCOS qcow2 image"

export URL=`curl --progress-bar https://builds.coreos.fedoraproject.org/streams/stable.json | jq -r '.architectures.aarch64.artifacts.qemu.formats."qcow2.xz".disk.location' `

curl $URL -o fcos.qcow2.xz

echo "Decompressing qcow2..."
xz -d fcos.qcow2.xz

echo "Done!"

echo "Building Docker image..."
docker build . -t guestfish

echo "Launching docker container to inject ignition file..."
docker run -v$PWD:/root/fcos -w /root/fcos guestfish /root/fcos/guestfish.sh
