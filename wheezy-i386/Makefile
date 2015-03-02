build: wheezy-chroot.tar
	docker build -t jmtd/debian:wheezy-i386 ./

wheezy-chroot.tar: wheezy-chroot
	cd wheezy-chroot && tar cf ../wheezy-chroot.tar ./

wheezy-chroot:
	mkdir -p wheezy-chroot
	debootstrap --arch i386 wheezy ./wheezy-chroot http://http.debian.net/debian
	chroot ./wheezy-chroot apt-get clean

clean:
	rm -f wheezy-chroot.tar
	rm -r wheezy-chroot

.PHONY: wheezy-chroot clean
