#!/bin/bash
set -e

IMAGE=mazzolino/armhf-debian:wheezy
DIST=wheezy

# Get current mkimage script
rm /tmp/mkimage -fR && mkdir -p /tmp/mkimage/mkimage
curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage.sh >/tmp/mkimage/mkimage.sh
curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage/debootstrap | sed 's/chroot "$rootfsDir" bash/chroot "$rootfsDir" \/bin\/bash/' >/tmp/mkimage/mkimage/debootstrap
chmod -R u+x /tmp/mkimage

# Bootstrap OS
PATH=/bin:/sbin:$PATH /tmp/mkimage/mkimage.sh -t $IMAGE debootstrap --arch=armhf $DIST

# Push image
docker push $IMAGE
