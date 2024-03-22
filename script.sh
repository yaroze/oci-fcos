#!/bin/bash

check_status(){
    if [ $? -eq 0 ]; then 
        echo "👍 OK!"
    else
        echo "❌ Failed!"
        exit 1
    fi
}

get_sha256sum(){
    SHA=($(sha256sum "$1"))
}

echo -n "Generating ignition file out of butane..."
podman run -i --rm quay.io/coreos/butane:release --pretty --strict < butane.bu > config.ign
check_status

ARCHITECTURES=("aarch64" "x86_64")

for ARCH_TYPE in "${ARCHITECTURES[@]}"; do
    echo "Checking if we already have the necessary images for $ARCH_TYPE..."

    export URL=$(curl -s "https://builds.coreos.fedoraproject.org/streams/stable.json" | jq -r ".architectures.$ARCH_TYPE.artifacts.qemu.formats.\"qcow2.xz\".disk.location")
    export SHA256=$(curl -s "https://builds.coreos.fedoraproject.org/streams/stable.json" | jq -r ".architectures.$ARCH_TYPE.artifacts.qemu.formats.\"qcow2.xz\".disk.\"sha256\"")
    export SHA256_UNCOMPRESSED=$(curl -s "https://builds.coreos.fedoraproject.org/streams/stable.json" | jq -r ".architectures.$ARCH_TYPE.artifacts.qemu.formats.\"qcow2.xz\".disk.\"uncompressed-sha256\"")

    if [ ! -f fcos_$ARCH_TYPE.qcow2 ]; then 
        echo "Uncompressed image doesn't exist. Checking if we have a compressed image here... 🤔"

        if [ ! -f fcos_$ARCH_TYPE.qcow2.xz ]; then
            echo -n "Compressed image doesn't exist either. Downloading... ⏳"
            # Fetch image URL and SHA256 sum based on architecture
            curl -s "$URL" -o fcos_$ARCH_TYPE.qcow2.xz
            check_status
            echo -n "Decompressing... ⏳"
            xz -k -d fcos_$ARCH_TYPE.qcow2.xz
            check_status
        else
            echo -n "Checking sha256sum for compressed image... ⏳"
            get_sha256sum fcos_$ARCH_TYPE.qcow2.xz
            if [ "${SHA[0]}" != "$SHA256_COMPRESSED" ]; then
                echo "known good: $SHA256_COMPRESSED"
                echo "calculated: ${SHA[0]}"
                false
                check_status
            fi
        fi
    fi

    echo "Comparing sha256sum of decompressed image... ⏳"
    get_sha256sum fcos_$ARCH_TYPE.qcow2
    if [ "${SHA[0]}" != "$SHA256_UNCOMPRESSED" ]; then 
        echo -n "sha256sum mismatch! "
        echo "known good: $SHA256_UNCOMPRESSED"
        echo "calculated: ${SHA[0]}"
        false
        check_status
        exit 1
    else
        true
        check_status
    fi

    echo "Building Docker image... if the image isn't built already or if guestfish.sh isn't updated, this might take a while... 🐳"
    echo -n "Logs are under $PWD/build_guestfish.log..."
    podman build . -t guestfish > build_guestfish.log 2>&1
    check_status

    echo "Launching podman container to inject ignition file... ⏳"
    podman run -v "$PWD:/root/fcos:z" -w /root/fcos guestfish /root/fcos/guestfish.sh fcos_$ARCH_TYPE.qcow2
done
