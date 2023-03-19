#!/bin/bash

check_status(){
        if [ $? -eq 0 ]
    then 
        echo "👍 OK!
"
    else
        echo "❌ Failed!
"
        exit 1
    fi
}

get_sha256sum(){
    SHA=($(sha256sum $1))
}

echo -n "Generating ignition file out of butane..."
docker  run -i -q --rm quay.io/coreos/butane:release --pretty --strict < butane.bu > ignition.ign
check_status


export URL=`curl -s https://builds.coreos.fedoraproject.org/streams/stable.json | jq -r '.architectures.aarch64.artifacts.qemu.formats."qcow2.xz".disk.location' `
export SHA256=`curl -s https://builds.coreos.fedoraproject.org/streams/stable.json | jq -r '.architectures.aarch64.artifacts.qemu.formats."qcow2.xz".disk."sha256"'`
export SHA256_UNCOMPRESSED=`curl -s https://builds.coreos.fedoraproject.org/streams/stable.json | jq -r '.architectures.aarch64.artifacts.qemu.formats."qcow2.xz".disk."uncompressed-sha256"'`

echo "Checking if we already have the necessary images..."

if [ ! -f fcos.qcow2 ]; then 
    echo "Uncompressed image doesn't exist. Checking if we have a compressed image here... 🤔
"

    if [ ! -f fcos.qcow2.xz ]; then
        echo -n "Compressed image doesn't exist either. Downloading... ⏳"
        curl -s $URL -o fcos.qcow2.xz
        check_status
        echo -n "Decompressing... ⏳"
        xz -d fcos.qcow2.xz
        check_status
    else
        echo -n "Checking sha256sum for compressed image... ⏳"
        get_sha256sum fcos.qcow2.xz
        if [ "$SHA" != "$SHA256_COMPRESSED" ]; then
            false
            check_status

        fi
    fi
fi


echo "Comparing sha256sum of decompressed image... ⏳"
get_sha256sum fcos.qcow2
if [ "$SHA" != "$SHA256_UNCOMPRESSED" ]; then 
    echo -n "
sha256sum mismatch! "
    false
    check_status
    exit 1
else
    true
    check_status
fi


echo "Building Docker image... if the image isn't build already or if guestfish.sh isn't updated, this might take a while... 🐳"
echo -n "Logs are under $PWD/build_guestfish.log..."
docker build . -t guestfish > build_guestfish.log 2>&1
check_status

echo "Launching docker container to inject ignition file... ⏳"
docker run -v$PWD:/root/fcos:z -w /root/fcos guestfish /root/guestfish.sh
