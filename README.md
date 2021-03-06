# Scripts for Debian Docker base images for armhf devices

[![Build Status](https://armdrone.strahlungsfrei.de/api/badges/armhf-docker-library/debian/status.svg)](https://armdrone.strahlungsfrei.de/armhf-docker-library/debian)

The Makefile and scripts can be used to build Docker base images for Debian-based distributions on armhf devices.

The images are tagged with (e.g. `armhfbuild/debian`) and without (e.g. `debian`) organization prefix. So you can build images which replace e.g. the official `debian` and `ubuntu` base images. That in turn allows building most images from the official Docker Registry without further changes.

By default, Debian Wheezy will be built.

## Examples

Build, tag and push Ubuntu Trusty, tag as latest:

    make build tags push IMAGE=ubuntu REPOSITORY_IMAGE=armhfbuild/ubuntu DIST=trusty LATEST=trusty ADDITIONAL_TAGS="14.04 14.04.2" DEBOOTSTRAP_ARGS="trusty http://ports.ubuntu.com/"

Update and push the updated version:

    make update IMAGE=ubuntu REPOSITORY_IMAGE=armhfbuild/ubuntu DIST=trusty LATEST=trusty ADDITIONAL_TAGS="14.04 14.04.2" DEBOOTSTRAP_ARGS="trusty http://ports.ubuntu.com/"

## Makefile variables

The following variables can be adjusted. The defaults are shown:

    IMAGE = debian
    REPOSITORY_IMAGE = armhfbuild/debian
    DIST = wheezy
    ADDITIONAL_TAGS = 7 7.8
    LATEST = wheezy
    ARCH = armhf
    DEBOOTSTRAP_ARGS =

## Makefile targets

### build

Debootstraps the base image and injects `qemu-user-static` (see [emulation support](#emulation-support)).

* Result: creates image `$IMAGE:$DIST` (e.g. `debian:wheezy`)

### tags

Creates suitable Docker tags for the built image.

* Result: creates image `$REPOSITORY_IMAGE:$DIST` (e.g. `armhfbuild/debian:wheezy`)
* Result: if latest, creates `$IMAGE:latest` and `$REPOSITORY_IMAGE:latest` (e.g. `debian:latest` and `armhfbuild/debian:latest`)
* Result: creates `$IMAGE:$tag` and `$REPOSITORY_IMAGE:$tag` for each tag defined in `ADDITIONAL_TAGS` (e.g. `debian:8` and `armhfbuild/debian:8`)

### push

Pushes the current images to the Docker Registry.

* Result: pushes `$REPOSITORY_IMAGE:$DIST` and `$REPOSITORY_IMAGE:latest` (e.g. `armhfbuild/debian:wheezy` and `armhfbuild/debian:latest`)
* Result: pushes `$REPOSITORY_IMAGE:$tag` for each tag defined in `ADDITIONAL_TAGS`  (e.g. `armhfbuild/debian:8`)

### update

Runs `apt-get dist-upgrade` on `$IMAGE:$DIST` (e.g. `debian:wheezy`).

## Emulation support

The `build` target copies the amd64 version of `qemu-arm-static` into the image. This means you can build and run ARM containers on your 64bit machine, as explained in [this post](https://groups.google.com/forum/#!msg/coreos-dev/YC-G_rVFnI4/ncS5bjxYWdc). The following command must be executed before building or running any ARM containers:

    sudo sh -c 'echo ":arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-arm-static:" >/proc/sys/fs/binfmt_misc/register'
