FROM jmtd/debian:jessie-amd64
MAINTAINER Jonathan Dowland <jmtd@debian.org>

# build environment
# libxml-writer-perl, see bugs.debian.org/719913
# python-minimal for something in the autosetup
RUN apt-get update \
    && apt-get install -y ikiwiki git lighttpd python-minimal \
                          libxml-writer-perl \
    && apt-get clean \
    && find /var/lib/apt/lists -type f -delete

RUN adduser --gecos "ikiwiki user" --disabled-password ikiwiki
WORKDIR /home/ikiwiki
ENV USER ikiwiki

ADD auto.setup /home/ikiwiki/
RUN chown ikiwiki auto.setup /var/www

RUN chown ikiwiki /usr/lib/cgi-bin

# Hacks so ikiwiki automator works
# so mkdir works
RUN rm -rf /var/www/html
# silence a non-fatal error
RUN chown ikiwiki /etc/ikiwiki/wikilist

# lighttpd configuration
RUN lighttpd-enable-mod cgi
# we may also decide to want userdirs

USER ikiwiki
# more todo
RUN git config --global user.name "ikiwiki-in-a-box automator" \
    && git config --global user.email null@example.org \
    && printf "password\npassword" | ikiwiki --setup auto.setup

# destdir (for e.g. external httpd)
# NOTE: permissions are fucked.
#VOLUME ["/home/ikiwiki/public_html/Ikiwiki-in-a-box"]
## repository (to push to)
#VOLUME ["/home/ikiwiki/Ikiwiki-in-a-box.git"]

EXPOSE 80
# XXX: ideally we will not be a privileged user. But what do we need to do?
# receive hooks, write to the wiki...
USER root

ADD lighttpd-ikiwiki.conf /etc/lighttpd/conf-enabled/

# back to root for the dir

CMD /usr/sbin/lighttpd -Df /etc/lighttpd/lighttpd.conf
