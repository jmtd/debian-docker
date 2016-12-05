FROM scratch
MAINTAINER Jonathan Dowland <jmtd@debian.org>
ADD root.tar /

# Unfortunately we have to use codenames here rather than something more
# static (stable/testing) because we wouldn't want the images to suddenly
# change suite when a new Debian release was made. Thus these greps will
# need to be updated to track the current release codenames
RUN if grep -q jessie /etc/apt/sources.list; then \
        echo "deb http://security.debian.org jessie/updates main contrib non-free" \
            >> /etc/apt/sources.list; \
    elif grep -q stretch /etc/apt/sources.list; then \
        echo "deb http://security.debian.org stretch/updates main contrib non-free" \
            >> /etc/apt/sources.list; \
    fi

RUN apt-get update \
	&& apt-get -y upgrade \
	&& apt-get -y --purge autoremove \
	&& apt-get clean \
	&& find /var/lib/apt/lists -type f -delete

LABEL org.redmars.docker.VcsType git
LABEL org.redmars.docker.VcsUrl  http://github.com/jmtd/debian-docker
LABEL org.redmars.docker.VcsRef  SUBSTITUTION_FAILED

CMD ["/bin/bash"]
