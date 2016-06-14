# debian-docker
scripts and Dockerfiles to build jmtd/debian\* docker images

What I use to build `jmtd/debian:*` docker images on the Docker registry.

## Description of images

 * **build**: This is a sid/unstable base image, variant *buildd*: this
   includes `apt`, `build-essential` and their dependencies. It's suitable
   as a base image for building a Debian package, or the basis of a *buildd*.

 * **jessie**: a base debian installation of *jessie* (current *stable*).
   Approx. 218M in size.

 * **wheezy**: a base debian installation of *wheezy* (*oldstable*).
   Approx 163M in size.

 * **wheezy-i386**: a base debian installation of the i386-architecture
   version of *wheezy*. This could be used for anything requiring a 32-bit
   toolchain. Approx 166M in size.

## Getting started

To build your own images, clone this repo, cd to the local path and run

```
sudo make release=jessie prefix=jmtd arch=amd64 mirror=http://httpredir.debian.org/debian/
```

All the arguments above are optional. The values in the example above are
the defaults. The resulting image would be tagged `jmtd/debian:jessie-amd64`.

## Proxy support

You can run make with a http_proxy option to use something like apt-cacher-ng:

```
sudo make http_proxy="http://10.10.5.1:3142"
```

If you do this, debootstrap will use this proxy to download packages.
Additionally a /etc/apt/apt.conf.d/01proxy file will be added to the finished
image, so that all future apt runs inside Docker will also use that proxy.

## Future work

I don't want to maintain a zillion different images, but there are a few other
variants that might be of use for people:

 * Now *jessie* is released, I'll probably add *jessie-i386* and phase out
   *wheezy-i386*.
 * Perhaps introduce floating release tags, e.g. `:stable`.
 * A `wine` base image, derived from (probably) `jessie-i386`.
 * Possibly a base X image, with x11vnc, uxterm and a lightweight window
   manager. Last I checked `openbox` was a bit smaller than `icewm`.
 * minimised images. As per Joey H's blog, The *Debian* images here are
   base Debian images, to avoid being misleading, but that makes them much
   larger than Docker's "semi-official" Debian images (twice as large). We
   could/should offer minimized images, starting with `--variant=minbase`
   but also incorporating other things, such as some of the techniques used
   by [emdebian](http://emdebian.org/). Just so long as we clearly label them
   as being modified from stock Debian.

## Further Reading

[what does docker.io run -it debian sh
run?](http://joeyh.name/blog/entry/docker_run_debian/) by Joey Hess, which
recommends <q>only trust docker images you build yourself</q>.

 — Jonathan Dowland <jmtd@debian.org>
