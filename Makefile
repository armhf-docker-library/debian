IMAGE = debian
REPOSITORY_IMAGE = armhfbuild/debian
DIST = jessie
ADDITIONAL_TAGS=7 7.8
LATEST = jessie
ARCH = armhf
DEBOOTSTRAP_ARGS ?= $(DIST)

default: build tags

build: bootstrap add-qemu

clean:
	rm .*.$(ARCH).$(DIST)

.tags.$(ARCH).$(DIST): build
	sudo docker tag -f $(IMAGE):$(DIST) $(REPOSITORY_IMAGE):$(DIST)
	if [ $(DIST) = $(LATEST) ]; then \
		sudo docker tag -f $(IMAGE):$(DIST) $(IMAGE):latest; \
		sudo docker tag -f $(IMAGE):$(DIST) $(REPOSITORY_IMAGE):latest; \
	fi
	for tag in $(ADDITIONAL_TAGS); do \
		sudo docker tag -f $(IMAGE):$(DIST) $(IMAGE):$$tag; \
		sudo docker tag -f $(IMAGE):$(DIST) $(REPOSITORY_IMAGE):$$tag; \
	done
	@touch $@

tags: .tags.$(ARCH).$(DIST)

.push.$(ARCH).$(DIST): .tags.$(ARCH).$(DIST)
	sudo docker push $(REPOSITORY_IMAGE):$(DIST)
	if [ $(DIST) = $(LATEST) ]; then sudo docker push $(REPOSITORY_IMAGE):latest; fi
	for tag in $(ADDITIONAL_TAGS); do \
		sudo docker push $(REPOSITORY_IMAGE):$$tag; \
	done
	@touch $@

push: .push.$(ARCH).$(DIST)

update: build update.sh
	sudo ./update.sh $(IMAGE):$(DIST)

mkimage.sh:
	# Get current mkimage script
	mkdir -p mkimage
	curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage.sh >mkimage.sh
	curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage/debootstrap | sed 's/chroot "$$rootfsDir" bash/chroot "$$rootfsDir" \/bin\/bash/' >mkimage/debootstrap
	chmod -R u+x mkimage mkimage.sh

.bootstrap.$(ARCH).$(DIST): mkimage.sh
	# Bootstrap OS
	PATH=/bin:/sbin:$(PATH) ./mkimage.sh -t $(IMAGE):$(DIST) debootstrap --arch=$(ARCH) --components=main,universe $(DEBOOTSTRAP_ARGS)
	@touch $@

bootstrap: .bootstrap.$(ARCH).$(DIST)

.add-qemu.$(ARCH).$(DIST): .bootstrap.$(ARCH).$(DIST)
	# Add qemu binary for emulation on x86_64
	echo -e "FROM $(IMAGE):$(DIST)\nADD qemu-arm-static /usr/bin/qemu-arm-static\n" >Dockerfile.qemu
	docker build -t $(IMAGE):$(DIST) -f Dockerfile.qemu .
	rm Dockerfile.qemu
	@touch $@

add-qemu: .add-qemu.$(ARCH).$(DIST)

$(DIST).tar: .bootstrap.$(ARCH).$(DIST)
	CONTAINER=$$(docker create $(IMAGE):$(DIST) /bin/bash) && \
	docker export -o $(DIST).tar $$CONTAINER && \
	docker rm $$CONTAINER

.PHONY: default build update bootstrap add-qemu tags push
