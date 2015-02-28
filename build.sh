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

# Add qemu bainry for emulation on x86_64
echo -e "FROM $IMAGE\nADD qemu-arm-static /usr/bin/qemu-arm-static\n" >Dockerfile.qemu
docker build -t $IMAGE -f Dockerfile.qemu .
rm Dockerfile.qemu

# Push image
docker push $IMAGE
