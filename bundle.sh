#!/usr/bin/env sh
# $id Bundler for Front-end Apps
# Copyright 2019-2020, VR25
# License: GPLv3+


(id=acc
installerName=install
tarballName=${id}_bundle
destination=/home/*/Desktop/git/AccA/app/src/main/res/raw

cd ${0%/*} 2>/dev/null
version=$(sed -n "s/^version=//p" module.prop)
versionCode=$(sed -n "s/^versionCode=//p" module.prop)

cp -u install-tarball.sh $destination/$installerName
cp -u _builds/${id}_${version}_\(${versionCode}\).tar.gz $destination/$tarballName)

echo
