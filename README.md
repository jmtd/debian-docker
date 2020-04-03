# debian-docker **⚠️** DEPRECATED AND ARCHIVED **⚠️**

----

> **⚠️** **DEPRECATED** **⚠️** - most of the reasons for this stuff have been addressed.
> please take a look at the [official Debian docker images](https://hub.docker.com/_/debian)
> and the [debuerreotype tooling](https://github.com/debuerreotype/debuerreotype) for
> building them reproducibly.
> 
> This repository will be archived read-only and no further updates made here.
> Thanks for all your input over the years!
> **⚠️**

----

scripts and Dockerfiles to build jmtd/debian\* docker images

What I use to build `jmtd/debian:*` docker images on the Docker registry.

## Description of images

 * **build**: This is a sid/unstable base image, variant *buildd*: this
   includes `apt`, `build-essential` and their dependencies. It's suitable
   as a base image for building a Debian package, or the basis of a *buildd*.

 * **stretch**: a base debian installation of *stretch* (current *stable*).
   Approx. 220M in size.

 * **jessie**: a base debian installation of *jessie* (*oldstable*).
   Approx. 218M in size.

 * **wheezy-i386**: a base debian installation of the i386-architecture
   version of *wheezy* (oldoldstable). This could be used for anything
   requiring a 32-bit toolchain. Approx 166M in size.

## Getting started

To build your own images run

```bash
sudo apt-get install git make debootstrap
git clone https://github.com/jmtd/debian-docker.git
cd debian-docker/
sudo make release=stretch prefix=jmtd arch=amd64 mirror=http://httpredir.debian.org/debian/
```

All the arguments above are optional. The values in the example above are
the defaults. The resulting image would be tagged `jmtd/debian:stretch-amd64`.

## Future work

I don't want to maintain a zillion different images, but there are a few other
variants that might be of use for people:

 * possibly move the `debootstrap` step to execute within a container, so you
   don't need it on your host system
 * Update the i386 variant image to stable
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
