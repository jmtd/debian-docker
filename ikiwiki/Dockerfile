FROM jmtd/debian:jessie-amd64
MAINTAINER Jonathan Dowland <jmtd@debian.org>

# root stuff #################################################################

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

ADD \
    auto.setup lighttpd.conf /home/ikiwiki/
RUN chown ikiwiki \
    auto.setup lighttpd.conf /home/ikiwiki/

# silence a non-fatal error
RUN chown ikiwiki /etc/ikiwiki/wikilist

RUN lighttpd-enable-mod cgi auth
# XXX: move away from using this

USER ikiwiki
# USER ikiwiki stuff #########################################################

RUN mkdir -p var/log/lighttpd var/run var/cache/lighttpd/compress

# more todo
RUN git config --global user.name "ikiwiki-in-a-box automator" \
    && git config --global user.email null@example.org \
    && printf "password\npassword" | ikiwiki --setup auto.setup

# destdir (for e.g. external httpd)
# NOTE: permissions are fucked.
#VOLUME ["/home/ikiwiki/public_html/Ikiwiki-in-a-box"]
## repository (to push to)
#VOLUME ["/home/ikiwiki/Ikiwiki-in-a-box.git"]

EXPOSE 8080
CMD /usr/sbin/lighttpd -Df /home/ikiwiki/lighttpd.conf
