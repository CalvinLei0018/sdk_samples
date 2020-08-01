#!/bin/sh

sed -i 's/bionic/focal/g' /etc/apt/sources.list
add-apt-repository universe
add-apt-repository multiverse
apt-get update
apt-get install --no-install-recommends gstreamer1.0-tools gstreamer1.0-alsa \
gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
gstreamer1.0-libav
apt-get install --no-install-recommends libgstreamer1.0-dev \
libgstreamer-plugins-base1.0-dev \
libgstreamer-plugins-good1.0-dev \
libgstreamer-plugins-bad1.0-dev
apt install --no-install-recommends \
gstreamer1.0-x \
libgstreamer1.0-dev \
libgstreamer-plugins-base1.0-dev \
gstreamer1.0-plugins-bad \
libgstreamer-plugins-bad1.0-dev \
libsoup2.4-dev \
libjson-glib-dev \
libnice-dev \
autoconf \
libtool \
gtk-doc-tools \
libglib2.0-dev \
gstreamer1.0-nice \
libssl-dev \
libreadline-dev \
gstreamer1.0-plugins-ugly \
libsrtp0-dev \
libsrtp2-dev
apt-get install --no-install-recommends libssl1.0-dev
apt clean
sed -i 's/focal/bionic/g' /etc/apt/sources.list
apt update
