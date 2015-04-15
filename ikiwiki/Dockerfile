FROM jmtd/debian:jessie
MAINTAINER Jonathan Dowland <jmtd@debian.org>

# build environment…
RUN apt-get update \
    && apt-get install -y ikiwiki git \
    && apt-get clean \
    && find /var/lib/apt/lists -type f -delete

RUN adduser --gecos "ikiwiki user" --disabled-password ikiwiki
WORKDIR /home/ikiwiki
USER ikiwiki

ADD auto.setup /home/ikiwiki/

# more todo
RUN git config --global user.name "ikiwiki-in-a-box automator" \
    && git config --global user.email null@example.org \
    && printf "password\npassword" | ikiwiki --setup auto.setup
