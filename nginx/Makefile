NGINX_VERSION:=1.13.7
NGINX_MODULES:= \
	ngx_devel_kit-0.3.0 \
	nginx-module-vts-0.1.15 \

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
	for MOD in $(NGINX_MODULES); do \
		if [ -d "build/$$MOD" ] ; then \
			rm -rf "build/$$MOD" ; \
		fi ; \
	done

	tar xvzf nginx-$(NGINX_VERSION).tar.gz -C build/
	for MOD in $(NGINX_MODULES) ; do \
		tar xvzf "$$MOD.tar.gz" -C build/ ; \
	done

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
		CONFIGURE_FLAGS='' ; \
		for MOD in $(NGINX_MODULES) ; do \
			CONFIGURE_FLAGS="$$CONFIGURE_FLAGS --add-module=$$(pwd)/../$$MOD" ; \
		done ; \
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
			$$CONFIGURE_FLAGS \
			\
			; \
		\
		make -j2 \
	)

	( \
		DST='../pyginx/nginx.exe' ; \
		cp build/nginx-$(NGINX_VERSION)/objs/nginx "$$DST" ; \
		chmod a+x "$$DST" \
	)

	rm -rf build/nginx-$(NGINX_VERSION)
	rm -rf build/nginx-module-vts-$(NGINX_VTS_VERSION)
