build: jessie-chroot.tar
	docker build -t jmtd/debian:jessie ./

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
