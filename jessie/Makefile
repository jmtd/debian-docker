build: jessie-chroot.tar Dockerfile
	docker build -t jmtd/debian:jessie ./
	rm Dockerfile

rev=$(shell git rev-parse --verify HEAD)
Dockerfile: Dockerfile.in
	sed 's/SUBSTITUTION_FAILED/$(rev)/' $< >$@

jessie-chroot.tar: jessie-chroot
	cd jessie-chroot && tar cf ../jessie-chroot.tar ./

jessie-chroot:
	mkdir -p jessie-chroot &&\
		debootstrap jessie ./jessie-chroot http://http.debian.net/debian &&\
		chroot ./jessie-chroot apt-get clean

clean:
	rm -f jessie-chroot.tar
	rm -r jessie-chroot

.PHONY: clean
