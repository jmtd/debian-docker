build: sid-chroot.tar
	docker build -t jmtd/debian:build ./

sid-chroot.tar: sid-chroot
	cd sid-chroot && tar cf ../sid-chroot.tar ./

sid-chroot:
	mkdir -p sid-chroot
	debootstrap --variant buildd sid ./sid-chroot http://httpredir.debian.org/debian/
	chroot ./sid-chroot apt-get clean

clean:
	rm -f sid-chroot.tar
	rm -r sid-chroot

.PHONY: sid-chroot clean
