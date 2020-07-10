#!/bin/sh

ROOT_DIR=$(pwd)
ARCHITECTURE=$(uname -m)
ROOT_DIR_NAME=${ROOT_DIR##*/}
INSTALL_PREFIX=${ROOT_DIR%/$ROOT_DIR_NAME*}/gstreamer-1.16/
INSTALL_LIB_DIR=${ROOT_DIR%/$ROOT_DIR_NAME*}/gstreamer-1.16/lib
if [ "$ARCHITECTURE" = "aarch64" ]; then
  #run the fan
  sudo jetson_clocks
fi

#gstreamer
sudo apt-get install --yes build-essential dpkg-dev flex bison autotools-dev automake liborc-dev autopoint libtool gtk-doc-tools libgstreamer1.0-dev
sudo apt install --yes libnice-dev gstreamer1.0-nice libssl-dev

#gstreamer plugins-base
sudo apt-get install --yes libxv-dev libasound2-dev libtheora-dev libogg-dev libvorbis-dev libopus-dev

#gstreamer plugins-good
sudo apt-get install --yes libbz2-dev libv4l-dev libvpx-dev libjack-jackd2-dev libsoup2.4-dev libpulse-dev

#gstreamer plugins-bad
sudo apt-get install --yes faad libfaad-dev libfaac-dev

#gstreamer plugins-ugly
sudo apt-get install --yes libx264-dev libmad0-dev

install_libnice() {
  echo "Install libnice"
  #libnice
  sudo apt install --yes python3-pip
  pip3 install meson
  PATH=~/.local/bin:$PATH
  sudo apt-get install libgnutls28-dev --yes
  sudo apt-get install ninja-build --yes
  git clone https://github.com/TeeVid/libnice.git
  cd libnice
  meson --prefix=/usr build && ninja -C build && sudo ninja -C build install
  cd $ROOT_DIR
  echo "libnice installed"
}

install_patchelf() {
  echo "Install patchelf"
  git clone https://github.com/NixOS/patchelf.git
  cd patchelf
  ./bootstrap.sh
  ./configure
  make
  sudo make install
}

install_libnice
install_patchelf

echo "Install GStreamer manually"
ROOT_GST_DIR=$ROOT_DIR/gst-1.16
mkdir $ROOT_GST_DIR
cd $ROOT_GST_DIR

git clone https://github.com/GStreamer/gstreamer.git
cd gstreamer
git checkout 1.16
git submodule init
git submodule update
libtoolize
./autogen.sh --prefix=$INSTALL_PREFIX --libdir=$INSTALL_LIB_DIR CXXFLAGS=-std=c++11
./autogen.sh --prefix=$INSTALL_PREFIX --libdir=$INSTALL_LIB_DIR CXXFLAGS=-std=c++11
make -j4
sudo make install
export LD_LIBRARY_PATH=$INSTALL_LIB_DIR
export PKG_CONFIG_PATH=$INSTALL_LIB_DIR/pkgconfig:$PKG_CONFIG_PATH
cd $ROOT_GST_DIR

git clone https://github.com/GStreamer/gst-plugins-base.git
cd gst-plugins-base
git checkout 1.16
sudo cp ${ROOT_DIR}/gstrtpbasedepayload.c $(pwd)
git submodule init
git submodule update
libtoolize
./autogen.sh --prefix=$INSTALL_PREFIX --libdir=$INSTALL_LIB_DIR CXXFLAGS=-std=c++11
./autogen.sh --prefix=$INSTALL_PREFIX --libdir=$INSTALL_LIB_DIR CXXFLAGS=-std=c++11
make -j4
sudo make install
cd $ROOT_GST_DIR

git clone https://github.com/GStreamer/gst-plugins-good.git
cd gst-plugins-good
git checkout 1.16
git submodule init
git submodule update
libtoolize
./autogen.sh --prefix=$INSTALL_PREFIX --libdir=$INSTALL_LIB_DIR CXXFLAGS=-std=c++11
./autogen.sh --prefix=$INSTALL_PREFIX --libdir=$INSTALL_LIB_DIR CXXFLAGS=-std=c++11
make -j4
sudo make install
cd ..

git clone https://github.com/GStreamer/gst-plugins-bad.git
cd gst-plugins-bad
git checkout 1.16
git submodule init
git submodule update
libtoolize
./autogen.sh --prefix=$INSTALL_PREFIX --libdir=$INSTALL_LIB_DIR CXXFLAGS=-std=c++11
./autogen.sh --prefix=$INSTALL_PREFIX --libdir=$INSTALL_LIB_DIR CXXFLAGS=-std=c++11
make -j4
sudo make install
cd ..

git clone https://github.com/GStreamer/gst-plugins-ugly.git
cd gst-plugins-ugly
git checkout 1.16
git submodule init
git submodule update
libtoolize
./autogen.sh --prefix=$INSTALL_PREFIX --libdir=$INSTALL_LIB_DIR CXXFLAGS=-std=c++11
./autogen.sh --prefix=$INSTALL_PREFIX --libdir=$INSTALL_LIB_DIR CXXFLAGS=-std=c++11
make -j4
sudo make install
cd ..

cd $ROOT_DIR

#install libnice one more time to be sure we use exactly this version
cd libnice
sudo ninja -C build install
cd ..

cd ${INSTALL_LIB_DIR}/gstreamer-1.0
if [ "$ARCHITECTURE" = "aarch64" ]; then
  sudo ln -s /usr/lib/${ARCHITECTURE}-linux-gnu/gstreamer-1.0/libgstnvarguscamerasrc.so libgstnvarguscamerasrc.so
  sudo ln -s /usr/lib/${ARCHITECTURE}-linux-gnu/gstreamer-1.0/libgstnvcompositor.so libgstnvcompositor.so
  sudo ln -s /usr/lib/${ARCHITECTURE}-linux-gnu/gstreamer-1.0/libgstnvdrmvideosink.so libgstnvdrmvideosink.so
  sudo ln -s /usr/lib/${ARCHITECTURE}-linux-gnu/gstreamer-1.0/libgstnveglglessink.so libgstnveglglessink.so
  sudo ln -s /usr/lib/${ARCHITECTURE}-linux-gnu/gstreamer-1.0/libgstnveglstreamsrc.so libgstnveglstreamsrc.so
  sudo ln -s /usr/lib/${ARCHITECTURE}-linux-gnu/gstreamer-1.0/libgstnvegltransform.so libgstnvegltransform.so
  sudo ln -s /usr/lib/${ARCHITECTURE}-linux-gnu/gstreamer-1.0/libgstnvivafilter.so libgstnvivafilter.so
  sudo ln -s /usr/lib/${ARCHITECTURE}-linux-gnu/gstreamer-1.0/libgstnvjpeg.so libgstnvjpeg.so
  sudo ln -s /usr/lib/${ARCHITECTURE}-linux-gnu/gstreamer-1.0/libgstnvtee.so libgstnvtee.so
  sudo ln -s /usr/lib/${ARCHITECTURE}-linux-gnu/gstreamer-1.0/libgstnvvidconv.so libgstnvvidconv.so
  sudo ln -s /usr/lib/${ARCHITECTURE}-linux-gnu/gstreamer-1.0/libgstnvvideo4linux2.so libgstnvvideo4linux2.so
  sudo ln -s /usr/lib/${ARCHITECTURE}-linux-gnu/gstreamer-1.0/libgstnvvideocuda.so libgstnvvideocuda.so
  sudo ln -s /usr/lib/${ARCHITECTURE}-linux-gnu/gstreamer-1.0/libgstnvvideosink.so libgstnvvideosink.so
  sudo ln -s /usr/lib/${ARCHITECTURE}-linux-gnu/gstreamer-1.0/libgstnvvideosinks.so libgstnvvideosinks.so
fi

FILE_LIBNICE=libgstnice.so
if [ ! -f "$FILE_LIBNICE" ]; then
  sudo ln -s /usr/lib/${ARCHITECTURE}-linux-gnu/gstreamer-1.0/${FILE_LIBNICE} ${FILE_LIBNICE}
fi
cd $ROOT_DIR

if [ "$ARCHITECTURE" = "aarch64" ]; then
  patchelf --set-rpath $INSTALL_LIB_DIR ${ROOT_DIR}/libs/jetson/debug/libteevid_sdk.so
  #patchelf --set-rpath $INSTALL_LIB_DIR ${ROOT_DIR}/libs/jetson/release/libteevid_sdk.so
else
  patchelf --set-rpath $INSTALL_LIB_DIR ${ROOT_DIR}/libs/desktop/debug/libteevid_sdk.so
  #patchelf --set-rpath $INSTALL_LIB_DIR ${ROOT_DIR}/libs/desktop/release/libteevid_sdk.so
fi

