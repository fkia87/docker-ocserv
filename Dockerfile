FROM alpine:latest

RUN apk update && apk add musl-dev iptables gnutls-dev gnutls-utils readline-dev libnl3-dev lz4-dev libseccomp-dev libev-dev

RUN buildDeps="xz openssl gcc autoconf make linux-headers"; \
	set -x \
	&& apk add $buildDeps \
	&& cd \
	&& wget http://ocserv.gitlab.io/www/download.html -O download.html \
	&& OC_VERSION=`sed -n 's/^.*The latest version of ocserv is \(.*\)$/\1/p' download.html` \
	&& OC_FILE="ocserv-$OC_VERSION" \
	&& rm -fr download.html \
	&& wget ftp://ftp.infradead.org/pub/ocserv/$OC_FILE.tar.xz \
	&& tar xJf $OC_FILE.tar.xz \
	&& rm -fr $OC_FILE.tar.xz \
	&& cd $OC_FILE \
	&& sed -i '/#define DEFAULT_CONFIG_ENTRIES /{s/96/200/}' src/vpn.h \
	&& ./configure \
	&& make -j"$(nproc)" \
	&& make install \
	&& mkdir -p /etc/ocserv \
	&& cd \
	&& rm -rf ./$OC_FILE \
	&& apk del --purge $buildDeps

# WORKDIR /etc/ocserv

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 4444

CMD ["ocserv", "-c", "/etc/ocserv/ocserv.conf", "-f"]
