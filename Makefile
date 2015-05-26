#!/usr/bin/make
# USAGE: 'sudo make' to build a jessie image (jmtd/debian:jessie).
# Define variables on the make command line to change behaviour
# e.g.
#       sudo make release=wheezy arch=i386 tag=wheezy-i386

# variables that can be overridden:
release ?= jessie
prefix  ?= jmtd
arch    ?= amd64
tag     ?= $(release)-$(arch)

build: $(tag)/root.tar $(tag)/Dockerfile
	docker build -t $(prefix)/debian:$(tag) $(tag)

rev=$(shell git rev-parse --verify HEAD)
$(tag)/Dockerfile: Dockerfile.in $(tag)
	sed 's/SUBSTITUTION_FAILED/$(rev)/' $< >$@

$(tag):
	mkdir $@

$(tag)/root.tar: roots/$(tag) $(tag)
	cd roots/$(tag) && tar cf ../../$(tag)/root.tar ./

roots/$(tag):
	mkdir -p $@ \
		&& debootstrap --arch $(arch) $(release) $@ http://http.debian.net/debian \
		&& chroot $@ apt-get clean

clean:
	rm -f $(tag)/root.tar $(tag)/Dockerfile
	rm -r roots/$(tag)
	test -d $(tag) && rmdir $(tag)

.PHONY: clean build
