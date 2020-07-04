FROM debian:buster-slim

ENV VARNISH_CONFIG  /etc/varnish/default.vcl
ENV VARNISH_STORAGE malloc,500m

# install varnish build stuff
RUN apt-get update && apt-get install -y --no-install-recommends \
            automake \
            autotools-dev \
            build-essential \
            ca-certificates \
            wget \
            libedit-dev \
            libgetdns-dev \
            libjemalloc-dev \
            libmhash-dev \
            libncurses-dev \
            libpcre3-dev \
            libtool \
            pkg-config \
            python3 \
            python3-docutils \
            python3-sphinx

# install varnish
ENV VARNISH_VERSION=6.4.0
RUN mkdir -p /usr/local/src && \
    cd /usr/local/src && \
    mkdir /usr/local/src/varnish && \
    wget https://varnish-cache.org/_downloads/varnish-${VARNISH_VERSION}.tgz && \
    tar -xzvf varnish-${VARNISH_VERSION}.tgz --directory /usr/local/src/varnish && \
    cd varnish/varnish-${VARNISH_VERSION} && \
    ./autogen.sh && \
    ./configure && \
    make install && \
    cd /usr/local/src && \
    rm -rf varnish

# install libvmod-dynamic
ENV LIBVMOD_DYNAMIC_VERSION=2.2.1

RUN cd /usr/local/src/ && \
    mkdir /usr/local/src/libvmod-dynamic && \
    wget https://github.com/nigoroll/libvmod-dynamic/archive/v${LIBVMOD_DYNAMIC_VERSION}.tar.gz && \
    tar -xzf v${LIBVMOD_DYNAMIC_VERSION}.tar.gz --directory /usr/local/src/libvmod-dynamic && \
    ls -al libvmod-dynamic && \
    cd libvmod-dynamic/libvmod-dynamic-${LIBVMOD_DYNAMIC_VERSION} && \
    ./autogen.sh && \
    ./configure && \
    make install && \
    cd /usr/local/src && \
    rm -rf libvmod-dynamic && \
    ldconfig

# add runtime dep for dns and cleanup
RUN apt-get install -y libgetdns10 && apt-get remove -y \
            automake \
            autotools-dev \
            build-essential \
            ca-certificates \
            wget \
            libedit-dev \
            libgetdns-dev \
            libjemalloc-dev \
            libmhash-dev \
            libncurses-dev \
            libpcre3-dev \
            libtool \
            pkg-config \
            python3 \
            python3-docutils \
            python3-sphinx \
            && rm -rf /var/lib/apt/lists/*

COPY entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint
ENTRYPOINT ["entrypoint"]

EXPOSE 80 8443
CMD []