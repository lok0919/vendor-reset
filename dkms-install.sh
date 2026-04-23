#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

commit_id="$(git rev-parse --short HEAD)"
dir_name="/tmp/vendor-reset-${commit_id}"

#echo "Installing version ${commit_id} to ${dir_name}"
mkdir -p $dir_name
git archive HEAD | tar -x -C $dir_name

sed -i "s/PACKAGE_VERSION=\"0.1.1\"/PACKAGE_VERSION=\"${commit_id}\"/g" $dir_name/dkms.conf

dkms add $dir_name
for k in /lib/modules/*; do
    dkms install vendor-reset/$commit_id -k "$(basename "$k")"
done
