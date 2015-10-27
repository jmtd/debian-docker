FROM jmtd/debian:jessie-amd64
MAINTAINER Jonathan Dowland <jmtd@debian.org>

# root stuff #################################################################

# deps from Bundle::IkiWiki
# Date::Parse -> libtimedate-perl
# Data::Dumper - in perl package

# python-minimal for something in the autosetup
# libxml-writer-perl, see bugs.debian.org/719913
RUN apt-get update \
    && apt-get install -y \
        git lighttpd python-minimal apache2-utils make \
        gettext gcc \
        libtext-markdown-discount-perl \
        libhtml-scrubber-perl \
        libhtml-template-perl \
        libhtml-parser-perl \
        liburi-perl \
        libxml-simple-perl \
        libtimedate-perl \
        libcgi-formbuilder-perl \
        libcgi-session-perl \
        libmail-sendmail-perl \
        libcgi-pm-perl \
        libyaml-libyaml-perl \
        libjson-perl \
        librpc-xml-perl \
        libxml-writer-perl \
    && apt-get clean \
    && find /var/lib/apt/lists -type f -delete

WORKDIR /usr/src

# obtain the git source
RUN git clone git://git.ikiwiki.info/ \
    && cd git.ikiwiki.info \
    && git checkout 3.20150610

# build and install ikiwiki
WORKDIR /usr/src/git.ikiwiki.info
RUN perl Makefile.PL \
    && make
RUN make pure_install

RUN adduser --gecos "ikiwiki user" --disabled-password ikiwiki
WORKDIR /home/ikiwiki
ENV USER ikiwiki

# silence a non-fatal error
# RUN chown ikiwiki /etc/ikiwiki/wikilist

ADD \
    auto.setup git-auth.conf lighttpd.conf /home/ikiwiki/
RUN chown ikiwiki \
    auto.setup git-auth.conf lighttpd.conf /home/ikiwiki/

USER ikiwiki
# USER ikiwiki stuff #########################################################

RUN mkdir -p var/log/lighttpd var/run var/cache/lighttpd/compress git

# more todo
RUN git config --global user.name "ikiwiki-in-a-box automator" \
    && git config --global user.email null@example.org \
    && printf "password\npassword" | ikiwiki --setup auto.setup

# set up htpasswd file (TODO: get Ikiwiki to read it too)
RUN htpasswd -cb /home/ikiwiki/htpasswd admin password

# Set up git repos for libdir (plugins) and templates (page templates)
RUN sh -xc 'for r in libdir templates; do \
        GIT_DIR=git/$r.git git init \
        && git clone git/$r.git $r \
        && echo "cd /home/ikiwiki/$r && git pull" > git/$r.git/hooks/post-update \
        && chmod +x git/$r.git/hooks/post-update \
        ; done'

# fix git repo settings for access via HTTP
RUN sh -xc 'for r in git/*.git; do \
        ( cd $r && git config http.receivepack true && git config receive.denynonfastforwards false ) \
        ; done'

EXPOSE 8080
CMD /usr/sbin/lighttpd -Df /home/ikiwiki/lighttpd.conf
