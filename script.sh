#!/bin/bash


helpFunction()
{
   echo ""
   echo "This script will download the latest Fedora CoreOS image for the specified architecture,"
   echo "check its sha256sum, and inject an ignition file into it."
   echo ""
   echo "Usage:"
   echo " ./script.sh [aarch64|amd64|both]"
   echo ""
   echo "Examples:"
   echo " ./script.sh aarch64"
   echo " ./script.sh amd64"
   echo " ./script.sh both"
   echo ""
   echo "You provided:"
   echo "$0 $@"
   echo ""
   
   exit 1 # Exit script after printing help
}


if [ -z $1 ]; then
    helpFunction "$@"
fi


if [ $1 != "aarch64" ] && [ $1 != "amd64" ] &&  [ $1 != "both" ]; then
  helpFunction "$@"
fi

if [ $"1" == "both" ]; then
    ARCHITECTURES=("aarch64" "amd64")
    else
        ARCHITECTURES=("$1")
fi




check_status(){
    if [ $? -eq 0 ]; then 
        echo "👍 OK!"
    else
        echo "❌ Failed!"
        exit 1
    fi
}

get_sha256sum(){
    SHA="$(sha256sum "$1" | awk '{print $1}')"
    
}

echo "Generating ignition file out of butane... 🔥"
echo -n "Make sure you edited the butane.bu file before running this script! 💡"
podman run -i --rm quay.io/coreos/butane:release --pretty --strict < butane.bu > config.ign
check_status


for ARCH_TYPE in "${ARCHITECTURES[@]}"; do
    echo "Checking if we already have the necessary images for $ARCH_TYPE..."

    URL=$(curl -s "https://builds.coreos.fedoraproject.org/streams/stable.json" | jq -r ".architectures.$ARCH_TYPE.artifacts.qemu.formats.\"qcow2.xz\".disk.location")
    SHA256_COMPRESSED=$(curl -s "https://builds.coreos.fedoraproject.org/streams/stable.json" | jq -r ".architectures.$ARCH_TYPE.artifacts.qemu.formats.\"qcow2.xz\".disk.\"sha256\"")
    SHA256_UNCOMPRESSED=$(curl -s "https://builds.coreos.fedoraproject.org/streams/stable.json" | jq -r ".architectures.$ARCH_TYPE.artifacts.qemu.formats.\"qcow2.xz\".disk.\"uncompressed-sha256\"")

    if [ ! -f fcos_"$ARCH_TYPE".qcow2 ]; then 
        echo "Uncompressed image doesn't exist. Checking if we have a compressed image here... 🤔"

        if [ ! -f fcos_"$ARCH_TYPE".qcow2.xz ]; then
            echo -n "Compressed image doesn't exist either. Downloading... ⏳"
            # Fetch image URL and SHA256 sum based on architecture
            curl -s "$URL" -o fcos_"$ARCH_TYPE".qcow2.xz
            check_status
            echo -n "Decompressing... ⏳"
            xz -k -d fcos_"$ARCH_TYPE".qcow2.xz
            check_status
        else
            echo -n "Checking sha256sum for compressed image... ⏳"
            get_sha256sum fcos_"$ARCH_TYPE".qcow2.xz
            if [ "${SHA[0]}" != "$SHA256_COMPRESSED" ]; then
                echo "known good: $SHA256_COMPRESSED"
                echo "calculated: ${SHA[0]}"
                false
                check_status
            fi
            check_status
            if [ ! -f fcos_"$ARCH_TYPE".qcow2 ]; then
                echo -n "Decompressing... ⏳"
                xz -k -d fcos_"$ARCH_TYPE".qcow2.xz
                check_status
            fi
        fi
          fi


    echo -n "Comparing sha256sum of decompressed image... ⏳"
    get_sha256sum fcos_$ARCH_TYPE.qcow2
    if [ "${SHA[0]}" != "$SHA256_UNCOMPRESSED" ]; then 
        echo -n "sha256sum mismatch! "
        echo "known good: $SHA256_UNCOMPRESSED"
        echo "calculated: ${SHA[0]}"
        echo ""
        echo "Tip: Has this image already been patched?"
        echo "     If so, please delete the image and try again."
        false
        check_status
        exit 1
    else
        true
        check_status
    fi

    echo "Building Guestfish Docker image... if the image isn't built already or if guestfish.sh has changed, this might take a while... 🐳"
    echo -n "Logs are under $PWD/build_guestfish.log..."
    podman build . -t guestfish > build_guestfish.log 2>&1
    check_status

    echo "Launching podman container to inject ignition file... ⏳"
    podman run --rm -t -v "$PWD:/root/fcos:z" -w /root/fcos guestfish /root/fcos/guestfish.sh fcos_$ARCH_TYPE.qcow2
    check_status
    echo "All done! 🎉"
done
