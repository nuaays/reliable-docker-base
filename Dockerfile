FROM centos:7

MAINTAINER xdf<xudafeng@126.com>

COPY ./CentOS7-Base-163.repo /etc/yum.repos.d/CentOS-Base.repo

RUN yum clean all && yum makecache

WORKDIR /temp

RUN yum install -y \
  xorg-x11-server-Xvfb \
  java-1.7.0-openjdk-devel \
  which \
  glibc.i686 \
  zlib.i686 \
  libgcc-4.8.5-4.el7.i686 \
  glx-utils \
  git \
  libstdc++.i686 \
  file \
  make \
  qemu-kvm \
  libvirt \
  virt-install \
  bridge-utils \
  gtk2 \
  libXtst \
  GConf2 \
  alsa-lib \
  xorg-x11-fonts* \
  libnotify \
  libtool \
  gcc-c++ \
  glib*

RUN dbus-uuidgen > /etc/machine-id

ENV LIBSODIUM_VERSION 1.0.3

RUN curl -O http://www.mirrorservice.org/sites/distfiles.macports.org/libsodium/1.0.3_1/libsodium-$LIBSODIUM_VERSION.tar.gz \
  && mkdir libsodium \
  && tar -zxvf libsodium-$LIBSODIUM_VERSION.tar.gz --strip-components 1 -C libsodium \
	&& cd ./libsodium && ./autogen.sh && ./configure \
	&& make && make install \
	&& ldconfig

ENV ZEROMQ_VERSION 4.1.4

RUN export sodium_CFLAGS="-I/usr/local/include" \
  && export sodium_LIBS="-L/usr/local/lib" \
  && export CPATH=/usr/local/include \
  && export LIBRARY_PATH=/usr/local/lib \
  && export LD_LIBRARY_PATH=/usr/local/lib \
  && export LD_RUN_PATH=/usr/local/lib \
  && export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
  && export CFLAGS=$(pkg-config --cflags libsodium) \
  && export LDFLAGS=$(pkg-config --libs libsodium) \
  && curl -O http://pkgs.fedoraproject.org/repo/pkgs/zeromq/zeromq-$ZEROMQ_VERSION.tar.gz/a611ecc93fffeb6d058c0e6edf4ad4fb/zeromq-$ZEROMQ_VERSION.tar.gz \
	&& tar -zxvf zeromq-$ZEROMQ_VERSION.tar.gz \
	&& cd ./zeromq-$ZEROMQ_VERSION \
	&& ./configure && make && make install \
  && echo "/usr/local/lib" >> /etc/ld.so.conf.d/libzmq.conf \
	&& ldconfig

ENV ROOT_DIR=/root

RUN git clone --depth=1 https://github.com/creationix/nvm.git $ROOT_DIR/.nvm

ENV NODE_VERSION=v5.11.1
ENV NVM_NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node

RUN source $HOME/.nvm/nvm.sh \
  && NVM_NODEJS_ORG_MIRROR=$NVM_NODEJS_ORG_MIRROR nvm install $NODE_VERSION

ENV PATH="$ROOT_DIR/.nvm/versions/node/$NODE_VERSION/bin:$PATH"

WORKDIR /

COPY ./entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
