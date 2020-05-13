FROM ubuntu:20.04

RUN apt-get update && \
DEBIAN_FRONTEND="noninteractive" TZ="Asia/Tokyo" apt-get install -y --no-install-recommends \
  automake \
  bison \
  clang \
  curl \
  g++-multilib \
  gcc-multilib \
  git \
  libncurses5-dev  \
  libssl-dev \
  libtool \
  llvm-dev \
  lzma-dev \
  make \
  mingw-w64 \
  patch \
  ruby \
  unzip

# install fpm to build packages (deb, rpm)
#RUN gem install fpm --no-document

# install osx cross compiling tools
RUN DEBIAN_FRONTEND="noninteractive" TZ="Asia/Tokyo" apt-get install -y --no-install-recommends \
  cmake \
  g++-arm-linux-gnueabihf \
  libc++-9-dev \
  libtool-bin \
  libxml2-dev \
  pkg-config \
  wget \
  xz-utils
RUN cd /opt/ && \
  git clone https://github.com/tpoechtrager/osxcross.git
RUn ls
RUN curl -L https://github.com/phracker/MacOSX-SDKs/releases/download/10.15/MacOSX10.15.sdk.tar.xz -o /opt/osxcross/tarballs/MacOSX10.15.sdk.tar.xz
RUN cd /opt/osxcross/tarballs && tar -xvf MacOSX10.15.sdk.tar.xz -C . && \
    cp -rf /usr/lib/llvm-9/include/c++ MacOSX10.15.sdk/usr/include/c++ && \
    cp -rf /usr/include/x86_64-linux-gnu/c++/9/bits/ MacOSX10.15.sdk/usr/include/c++/v1/bits && \
    tar -cJf MacOSX10.15.sdk.tar.xz MacOSX10.15.sdk
RUN UNATTENDED=y SDK_VERSION=10.15 OSX_VERSION_MIN=10.13 /opt/osxcross/build.sh
#COPY MacOSX10.15.sdk.tar.bz2 /opt/osxcross/tarballs/
#RUN echo "\n" | bash /opt/osxcross/build.sh
RUN rm -rf /opt/osxcross/tarballs/*
ENV PATH /opt/osxcross/target/bin:$PATH
ENV SHELL /bin/bash

## install msitools
#RUN cd /tmp && wget https://launchpad.net/ubuntu/+archive/primary/+files/gcab_0.6.orig.tar.xz && tar -xf gcab_0.6.orig.tar.xz && cd gcab-0.6 && ./configure && make && make install
#
#RUN cd /tmp && wget https://launchpad.net/ubuntu/+archive/primary/+files/msitools_0.94.orig.tar.xz && tar -xf msitools_0.94.orig.tar.xz && cd msitools-0.94 && ./configure && make && make install

# install mingw packages
RUN mkdir /tmp/x86_64 && cd /tmp/x86_64 \
  && wget http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-unibilium-2.1.0-1-any.pkg.tar.xz \
  && wget http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-onigmo-6.2.0-1-any.pkg.tar.xz \
  && wget http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-pdcurses-4.1.0-3-any.pkg.tar.xz \
  && wget http://repo.msys2.org/mingw/x86_64/mingw-w64-x86_64-libiconv-1.16-1-any.pkg.tar.xz \
  && tar Jxf mingw-w64-x86_64-unibilium-2.1.0-1-any.pkg.tar.xz \
  && tar Jxf mingw-w64-x86_64-onigmo-6.2.0-1-any.pkg.tar.xz \
  && tar Jxf mingw-w64-x86_64-pdcurses-4.1.0-3-any.pkg.tar.xz \
  && tar Jxf mingw-w64-x86_64-libiconv-1.16-1-any.pkg.tar.xz \
  && cp -rp mingw64/* /usr/x86_64-w64-mingw32/

# arm-linux-gnuebihf
RUN cd /tmp && wget https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.2.tar.gz \
  && mkdir /tmp/arm-linux-gnueabihf && cd /tmp/arm-linux-gnueabihf \
  && tar zxf ../ncurses-6.2.tar.gz && cd ncurses-6.2 \
  && ./configure --prefix=/usr/arm-linux-gnueabihf/ --host=arm-linux-gnueabihf --without-ada --enable-warnings \
  --without-normal --enable-pc-files --with-shared --disable-stripping --without-pkg-config \
  && make install

ONBUILD WORKDIR /home/mruby/code
ONBUILD ENV GEM_HOME /home/mruby/.gem/

ONBUILD ENV PATH $GEM_HOME/bin/:$PATH
ONBUILD ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/
