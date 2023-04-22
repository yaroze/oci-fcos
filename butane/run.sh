#!/bin/bash
DEBUG=false



runbutane() {
  echo "Running butane."
  butane --pretty /oci-fcos/$2
}

doitforme() {
  echo "Running butane and injecting to qcow2 file. This might take a while..."
  butane --pretty /oci-fcos/$2 > /tmp/config.ign
  echo "Getting the boot partition from the qcow2 file..."
  fs_boot_path=$(virt-filesystems -a $3 -l | grep boot | awk -F ' ' '{print $1}')

  echo "Running guestfish..."
  /usr/bin/guestfish <<EOF
echo "Adding qcow2 file"
add $3
echo "Opening qcow2 file..."
run
echo "Mounting..."
  mount "$fs_boot_path" /
  mkdir /ignition
  echo "Uploading ignition..."
  copy-in /tmp/config.ign /ignition/
  echo "Done!"
  unmount-all 
  exit
EOF
}



case $1 in
  "-h")
    echo "Usage: docker run -v $PWD:/oci-fcos oci-fcos [-a|-b <file1> <file2>|-h][-d]"
    echo "-b: Run butane. Needs extra arguments. Outputs the ignition file to stdout."
    echo "Example:"
    echo "    docker run -v $PWD:/oci-fcos oci-fcos -b <butane file>"
    echo "-a: Does everything for you. Needs extra arguments:"
    echo "Example:"
    echo "    docker run -v $PWD:/oci-fcos oci-fcos -a <butane file> <qcow2 file>"
    echo "-s: Opens a shell inside the container."
    echo "-d: Enable debug mode."
    echo "-h: Show this help message. This is the default if no option is specified."
    exit 0
    ;;
  "-d")
    DEBUG=true
    set -x
    shift
    ;;
  "-b")
    if [ $# -ne 2 ]; then
      echo "Error: Invalid number of arguments for -b option. Use -h for help."
      exit 1
    fi
    if [ ! -e "$1" ] || [ ! -e "$2" ]; then
      echo "Error: The specified file does not exist. Use -h for help."
      exit 1
    fi
    runbutane "$2"
    exit $? # Pass the exit code of the function
    ;;
  "-s")
    /bin/bash
    exit 0
    ;;
  "-a")
    shift
    cd /oci-fcos
    if [ $# -ne 2 ]; then
      echo "Error: Invalid number of arguments for -b option. Use -h for help."
      exit 1
    fi
    if [ ! -e "$1" ] || [ ! -e "$2" ]; then
      echo "Error: One or both of the specified files does not exist. Use -h for help."
      exit 1
    fi
    doitforme "$1" "$2"
    exit $? # Pass the exit code of the function
    ;;
  *)
    echo "Error: Invalid option. Use -h for help."
    exit 1
    ;;
esac


