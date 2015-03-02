FROM scratch
MAINTAINER Jonathan Dowland <jmtd@debian.org>
ADD wheezy-chroot.tar /
RUN apt-get update \
	&& apt-get -y upgrade \
	&& apt-get -y autoremove \
	&& apt-get clean \
	&& find /var/lib/apt/lists -type f -delete
CMD ["/bin/bash"]
