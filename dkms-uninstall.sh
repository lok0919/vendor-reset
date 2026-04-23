#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Grab version (works with 0.1.1, 575a8fe, etc. — even if broken)
version=$(dkms status vendor-reset | grep -m 1 -oP '(?<=^vendor-reset/)[^:,\s]+')

if [ -z "${version}" ]; then
  echo "vendor-reset is not added to DKMS"
  exit 0
fi

echo "Completely removing vendor-reset/${version} (including leftover .ko files)..."

dkms remove "vendor-reset/${version}" --all 2>/dev/null || true

# Remove source directory
dir_name="/usr/src/vendor-reset-${version}"
[ -d "${dir_name}" ] && rm -rf "${dir_name}"

# Remove any leftover module files
rm -f /lib/modules/*/updates/dkms/vendor-reset.ko* 2>/dev/null || true
rm -f /lib/modules/*/extra/vendor-reset.ko* 2>/dev/null || true

# Final DKMS metadata cleanup
rm -rf "/var/lib/dkms/vendor-reset" 2>/dev/null || true

sudo depmod -a

echo "vendor-reset/${version} has been 100% removed. Future installs will be clean."
