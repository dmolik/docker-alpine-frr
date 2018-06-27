FROM alpine:latest

RUN apk update \
	apk upgrade \
	&& apk add c-ares pcre pcre2 libnfnetlink json-c \
	&& apk add --no-cache \
		--virtual .build-dependencies make gcc musl-dev flex bison autoconf automake c-ares-dev json-c-dev curl libtool pcre2-dev pcre-dev python-dev bsd-compat-headers linux-headers libnfnetlink-dev \
	&& mkdir /root/frr \
	&& cd /root/frr \
	&& curl -L https://github.com/FRRouting/frr/archive/frr-5.0.tar.gz | tar xz --strip-components=1 -C . \
	&& autoreconf -i -f \
	&& ./configure  CFLAGS="-O2 -pipe" \
		--enable-fpm --enable-cumulus --enable-datacenter \
		--disable-doc \
		--prefix=/usr --sysconfdir=/etc/frr --localstatedir=/run/frr \
		--disable-static  --disable-ripd --disable-ripngd \
		--disable-isisd --disable-watchfrr --disable-pimd \
		--disable-vtysh \
		--disable-babeld --disable-ldpd \
	&& make -j4 \
	&& make DESTDIR=/root/frr-release install \
	&& find   /root/frr-release -path \*bin\* -type f -not -name frr\* | xargs strip \
	&& find   /root/frr-release -name \*.so\* | xargs strip \
	&& apk del .build-dependencies \
	&& cd / \
	&& rm -rf /root/frr-release/usr/include \
	&& rm -rf /root/frr-release/usr/lib/*.la \
	&& rm -rf /root/frr-release/usr/lib/frr/modules/*.la \
	&& rm -rf /root/frr \
	&& cp -R  /root/frr-release/* / \
	&& rm -rf /root/frr-release \
	&& rm -rf /var/cache/apk/* \
	&& addgroup -S frr \
	&& adduser -S -D -h /run/frr -s /sbin/nologin -G frr -g frr frr
