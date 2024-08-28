#!/bin/sh

function check_root() {
    echo "Checking root privileges..."

    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root" >&2
        exit 1
    fi
}

check_root

echo "Checking available architectures..."
dpkg-architecture --list | grep "BUILD_ARCH=" | awk -F'=' '{print $2}' > architectures.txt
dpkg --print-foreign-architectures >> architectures.txt

echo "Select the architecture:"
options=()
while read -r line; do
    options+=("$line")
done < architectures.txt

select arch in "${options[@]}"; do
    if [[ " ${options[*]} " =~ " ${arch} " ]]; then
        echo "Selected architecture: $arch"
        break
    else
        echo "Invalid selection! Please choose a number from 1 to ${#options[@]}."
    fi
done

echo "Listing installed packages for the specified architecture..."
apt list --installed | grep "$arch" | awk -F'/' '{print $1}' > installed_packages.txt
cat "installed_packages.txt"

while read -r line; do
    package_name=$(echo "$line" | cut -d'/' -f1)
    if [ -n "$package_name" ]; then
        echo "Processing package: $package_name:$arch"
        dpkg --purge --force-all "$package_name:$arch"
    fi
done < installed_packages.txt

echo "Removing architecture:"
dpkg --remove-architecture "$arch"

echo "Checking for broken packages..."
dpkg --configure -a 2>&1 | grep "^dpkg: error processing package" | awk '{print $5}' | sort -u > broken_packages.txt
while read -r line; do
    package_name=$(echo "$line" | cut -d':' -f1)
    if [ -n "$package_name" ]; then
        echo "Processing package: $package_name"
        apt install --reinstall "$package_name"
    fi
done < broken_packages.txt

echo "Cleaning up..."
rm installed_packages.txt
rm broken_packages.txt
rm architectures.txt

exit 0
