#!/usr/bin/make
# USAGE: 'sudo make' to build a jessie image (jmtd/debian:jessie).
# Define variables on the make command line to change behaviour
# e.g.
#       sudo make release=wheezy arch=i386 tag=wheezy-i386

# variables that can be overridden:
release ?= jessie
prefix  ?= jmtd
arch    ?= amd64
mirror  ?= http://httpredir.debian.org/debian/
tag     ?= $(release)-$(arch)

build: $(tag)/root.tar $(tag)/Dockerfile
	docker build -t $(prefix)/debian:$(tag) $(tag)

rev=$(shell git rev-parse --verify HEAD)
$(tag)/Dockerfile: Dockerfile.in $(tag)
	sed 's/SUBSTITUTION_FAILED/$(rev)/' $< >$@

$(tag):
	mkdir $@

$(tag)/root.tar: roots/$(tag).ok $(tag)
	cd roots/$(tag) \
		&& tar -c --numeric-owner -f ../../$(tag)/root.tar ./

roots/$(tag).ok:
	debootstrap --arch $(arch) $(release) roots/$(tag) $(mirror) \
		&& chroot roots/$(tag) apt-get clean
	if [ "$(http_proxy)" ]; then \
		echo 'Acquire::HTTP::Proxy "$(http_proxy)";' > roots/$(tag)/etc/apt/apt.conf.d/01proxy; \
	fi
	touch $@

clean:
	rm -f $(tag)/root.tar $(tag)/Dockerfile roots/$(tag).ok
	rm -r roots/$(tag)
	test -d $(tag) && rmdir $(tag)

.PHONY: clean build
