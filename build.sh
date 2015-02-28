#!/bin/bash
set -e

IMAGE=mazzolino/armhf-debian
DIST=wheezy
IMAGE_WITH_DIST=$IMAGE:$DIST

# Get current mkimage script
rm /tmp/mkimage -fR && mkdir -p /tmp/mkimage/mkimage
curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage.sh >/tmp/mkimage/mkimage.sh
curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage/debootstrap | sed 's/chroot "$rootfsDir" bash/chroot "$rootfsDir" \/bin\/bash/' >/tmp/mkimage/mkimage/debootstrap
chmod -R u+x /tmp/mkimage

# Bootstrap OS
PATH=/bin:/sbin:$PATH /tmp/mkimage/mkimage.sh -t ${IMAGE_WITH_DIST} debootstrap --arch=armhf $DIST

# Add qemu bainry for emulation on x86_64
echo -e "FROM ${IMAGE_WITH_DIST}\nADD qemu-arm-static /usr/bin/qemu-arm-static\n" >Dockerfile.qemu
docker build -t ${IMAGE_WITH_DIST} -f Dockerfile.qemu .
rm Dockerfile.qemu

# Test image
docker run --rm ${IMAGE_WITH_DIST} apt-get check -qq
if [ $? -eq 0 ]; then
  # Push image
  docker push ${IMAGE_WITH_DIST}
  # Tag & push latest
  docker tag -f ${IMAGE_WITH_DIST} $IMAGE:latest
  docker push $IMAGE:latest
fi
