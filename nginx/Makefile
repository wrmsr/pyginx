NGINX_VERSION:=1.13.7
NGINX_VTS_VERSION:=0.1.15

.PHONY: all
all:

.PHONY: clean
clean:
	rm -rf build

.PHONY: install
install: install-nginx

.PHONY: install-nginx
install-nginx:
	if [ ! -d build ] ; then \
		mkdir build ; \
	fi

	if [ -d build/nginx-$(NGINX_VERSION) ] ; then \
		rm -rf build/nginx-$(NGINX_VERSION) ; \
	fi
	if [ -d build/nginx-module-vts-$(NGINX_VTS_VERSION) ] ; then \
		rm -rf build/nginx-module-vts-$(NGINX_VTS_VERSION) ; \
	fi

	tar xvzf nginx-$(NGINX_VERSION).tar.gz -C build/
	tar xvzf nginx-module-vts-$(NGINX_VTS_VERSION).tar.gz -C build/

	( \
		set -e ; \
		\
		cd build/nginx-$(NGINX_VERSION) ; \
		\
		BREW_CFLAGS='' ; \
		BREW_LDFLAGS='' ; \
		if [ "$$(uname)" = "Darwin" ] && command -v brew ; then \
			BREW_CFLAGS="-I$$(brew --prefix openssl)/include -I$$(brew --prefix pcre)/include" ; \
			BREW_LDFLAGS="-L$$(brew --prefix openssl)/lib -L$$(brew --prefix pcre)/lib" ; \
		fi ; \
		\
		./configure \
			--with-cc-opt="-g -O2 -fstack-protector $$BREW_CFLAGS" \
			--with-ld-opt="$$BREW_LDFLAGS" \
			\
			--with-debug \
			--with-ipv6 \
			--with-pcre \
			\
			--with-http_gzip_static_module \
			--with-http_ssl_module \
			--with-http_stub_status_module \
			--with-http_v2_module \
			\
			--add-module="$$(pwd)/../nginx-module-vts-$(NGINX_VTS_VERSION)" \
			\
			; \
		\
		make \
	)

	( \
		DST='../pyginx/nginx.exe' ; \
		cp build/nginx-$(NGINX_VERSION)/objs/nginx "$$DST" ; \
		chmod a+x "$$DST" \
	)

	rm -rf build/nginx-$(NGINX_VERSION)
	rm -rf build/nginx-module-vts-$(NGINX_VTS_VERSION)
