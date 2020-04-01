# https://nginx.org/download/nginx-1.17.9.tar.gz
# https://github.com/vision5/ngx_devel_kit

NGINX_VERSION:=1.17.9
NGINX_MODULES:= \
	ngx_devel_kit-0.3.1 \
	Form-input-nginx-module-0.12 \
	nginx-module-vts-0.1.18 \
	nginx-module-sts-0.1.1 \
	nginx-module-stream-sts-0.1.1 \
	nginx-statsd-0.0.1 \
	set-misc-nginx-module-0.32 \

.PHONY: all
all:

.PHONY: clean
clean:
	rm -rf build

.PHONY: patch-begin
build: clean
	if ! [ -d "build/nginx-$(NGINX_VERSION)" ] ; then \
		tar xvzf nginx-$(NGINX_VERSION).tar.gz -C build/ ; \
		(cd build && cp -rv nginx-$(NGINX_VERSION) nginx-$(NGINX_VERSION)-patch) ; \
	fi

.PHONY: patch-end
build:
	(cd build && diff -ruN nginx-$(NGINX_VERSION) nginx-$(NGINX_VERSION)-patched > ../nginx-$(NGINX_VERSION).patch)

.PHONY: build
build:
	-mkdir build
	-rm build/nginx.exe

	if ! [ -d "build/nginx-$(NGINX_VERSION)" ] ; then \
		tar xvzf nginx-$(NGINX_VERSION).tar.gz -C build/ ; \
		(cd build/nginx-$(NGINX_VERSION) && patch -p1 < ../../nginx-$(NGINX_VERSION).patch) ; \
	fi

	for MOD in $(NGINX_MODULES) ; do \
		if ! [ -d "build/$$MOD" ] ; then \
			tar xvzf "$$MOD.tar.gz" -C build/ ; \
		fi ; \
	done

	( \
		set -e ; \
		\
		cd build/nginx-$(NGINX_VERSION) ; \
		\
		CFLAGS="$$CFLAGS -g -O2 -fstack-protector" ; \
		LDFLAGS="$$LDFLAGS" ; \
		\
		if [ "$$(uname)" = "Darwin" ] && command -v brew ; then \
			CFLAGS="$$CFLAGS -I$$(brew --prefix openssl)/include -I$$(brew --prefix pcre)/include" ; \
			LDFLAGS="$$LDFLAGS -L$$(brew --prefix openssl)/lib -L$$(brew --prefix pcre)/lib" ; \
		fi ; \
		\
		CONFIGURE_FLAGS='' ; \
		for MOD in $(NGINX_MODULES) ; do \
			CONFIGURE_FLAGS="$$CONFIGURE_FLAGS --add-module=$$(pwd)/../$$MOD" ; \
		done ; \
		\
		if ! [ -f "build/nginx-$(NGINX_VERSION)/objs/nginx" ] ; then \
			./configure \
				--with-cc-opt="$$CFLAGS" \
				--with-ld-opt="$$LDFLAGS " \
				\
				--with-debug \
				--with-ipv6 \
				--with-stream \
				--with-threads \
				\
				--with-http_addition_module \
				--with-http_gzip_static_module \
				--with-http_slice_module \
				--with-http_ssl_module \
				--with-http_stub_status_module \
				--with-http_sub_module \
				--with-http_v2_module \
				\
				$$CONFIGURE_FLAGS \
				\
				; \
			\
			make -j8 ; \
		fi ; \
	)

	cp build/nginx-$(NGINX_VERSION)/objs/nginx build/nginx.exe
	chmod a+x build/nginx.exe
