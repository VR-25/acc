#!/usr/bin/env sh
# ${1:-id} Bundler for Front-end App
# Copyright (c) 2019, VR25 (xda-developers.com)
# License: GPLv3+


(id=acc
installerName=install
tarballName=${id}_bundle
destination=/mnt/d/Desktop/AccA/app/src/main/res/raw

cd ${0%/*} 2>/dev/null
versionCode=$(sed -n "s/^versionCode=//p" module.prop)

cp -u install-tarball.sh $destination/$installerName
cp -u _builds/${id}-${versionCode}/${id}-${versionCode}.tar.gz $destination/$tarballName)

read -p "(i) Press ENTER to continue..."
echo
