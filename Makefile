IMAGE = debian
REPOSITORY_IMAGE = armhfbuild/debian
DIST = wheezy

default: build tags

build: bootstrap add-qemu

.tags.$(DIST): build
	sudo docker tag -f $(IMAGE):$(DIST) $(REPOSITORY_IMAGE):$(DIST)
	if [ $(DIST) = 'wheezy' ]; then sudo docker tag -f $(IMAGE):$(DIST) $(REPOSITORY_IMAGE):latest; fi
	@touch $@

tags: .tags.$(DIST)

.push.$(DIST): .tags.$(DIST)
	sudo docker push $(REPOSITORY_IMAGE):$(DIST)
	@touch $@

push: .push.$(DIST)

mkimage.sh:
	# Get current mkimage script
	mkdir -p mkimage
	curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage.sh >mkimage.sh
	curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage/debootstrap | sed 's/chroot "$rootfsDir" bash/chroot "$rootfsDir" \/bin\/bash/' >mkimage/debootstrap
	chmod -R u+x mkimage{,.sh}

.bootstrap.$(DIST): mkimage.sh
	# Bootstrap OS
	PATH=/bin:/sbin:$PATH sudo /tmp/mkimage/mkimage.sh -t $(IMAGE):$(DIST) debootstrap --arch=armhf $(DIST)
	@touch $@

bootstrap: .bootstrap.$(DIST)

.add-qemu.$(DIST): .bootstrap.$(DIST)
	# Add qemu binary for emulation on x86_64
	echo -e "FROM $(IMAGE):$(DIST)\nADD qemu-arm-static /usr/bin/qemu-arm-static\n" >Dockerfile.qemu
	sudo docker build -t $(IMAGE):$(DIST) -f Dockerfile.qemu .
	rm Dockerfile.qemu
	@touch $@

add-qemu: .add-qemu.$(DIST)

.PHONY: default build bootstrap add-qemu tags push
