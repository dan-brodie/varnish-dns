FROM alpine:3.12 as vmod-dynamic-builder
WORKDIR /build
RUN apk update
RUN apk add --quiet ca-certificates curl wget tar gzip jq
RUN wget -O libvmod-dynamic.tar.gz https://github.com/nigoroll/libvmod-dynamic/archive/v2.2.1.tar.gz
RUN tar -zxvf libvmod-dynamic.tar.gz && mv libvmod-dynamic-2.2.1 libvmod-dynamic
RUN apk add --quiet build-base gcc make automake autoconf libtool varnish pcre-dev pkgconf varnish-dev file python3 py3-docutils
WORKDIR /build/libvmod-dynamic
RUN ls -al && chmod +x autogen.sh && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make && \
    make check && \
    make install

FROM alpine:3.12

ENV VARNISH_CONFIG /usr/local/etc/varnish/default.vcl
ENV VARNISH_STORAGE malloc,500M

RUN  apk --no-cache add varnish bind-tools

COPY --from=vmod-dynamic-builder  /usr/local/lib/varnish/vmods/libvmod_dynamic.so  /usr/local/lib/varnish/vmods/libvmod_dynamic.so

ENTRYPOINT ["/bin/sh", "-o", "pipefail", "-c", "varnishd -f ${VARNISH_CONFIG} -s ${VARNISH_STORAGE} | varnishncsa -F '%h %l %u %t \"%r\" %s %b \"%{Referer}i\" \"%{User-agent}i\" \"%{Varnish:handling}x\"'"]

EXPOSE 80

CMD []