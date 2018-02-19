NGINX_VERSION:=1.13.7
NGINX_MODULES:= \
	ngx_devel_kit-0.3.0 \
	form-input-nginx-module-0.12 \
	nginx-module-vts-0.1.15 \
	set-misc-nginx-module-0.31 \

.PHONY: all
all:

.PHONY: clean
clean:
	rm -rf build

.PHONY: build
build:
	-mkdir build
	-rm build/nginx.exe

	if ! [ -d "build/nginx-$(NGINX_VERSION)" ] ; then \
		tar xvzf nginx-$(NGINX_VERSION).tar.gz -C build/ ; \
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
			make -j2 ; \
		fi ; \
	)

	cp build/nginx-$(NGINX_VERSION)/objs/nginx build/nginx.exe
	chmod a+x build/nginx.exe
