NGINX_VERSION:=1.13.7
NGINX_MODULES:= \
	ngx_devel_kit-0.3.0 \
	form-input-nginx-module-0.12 \
	lua-nginx-module-0.10.11 \
	nginx-module-vts-0.1.15 \
	set-misc-nginx-module-0.31 \
	stream-lua-nginx-module-0.0.3 \

LUAJIT_VERSION:=2.1.0-beta3

.PHONY: all
all:

.PHONY: clean
clean:
	rm -rf build

.PHONY: build
build:
	-mkdir build ; \

	( \
		set -e ; \
		\
		if [ ! -z "$$MANYLINUX" ] ; then \
			CFLAGS="$$CFLAGS -std=gnu99" ; \
		fi ; \
		\
		if [ ! -d "build/luajit" ] ; then \
			tar xvzf LuaJIT-$(LUAJIT_VERSION).tar.gz -C build/ ; \
			DST="$$(pwd)/build/luajit" ; \
			(cd build/LuaJIT-$(LUAJIT_VERSION) && CFLAGS="$$CFLAGS" make PREFIX="$$DST" -j 2 install) ; \
		fi \
	)

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
		export LUAJIT="$$(pwd)/build/luajit" ; \
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
		export LUAJIT_LIB="$$LUAJIT/lib" ; \
		export LUAJIT_INC="$$LUAJIT/include/luajit-2.1" ; \
		\
		./configure \
			--with-cc-opt="-g -O2 -fstack-protector $$BREW_CFLAGS" \
			--with-ld-opt="$$BREW_LDFLAGS -Wl,-rpath,$$LUAJIT_LIB" \
			\
			--with-debug \
			--with-ipv6 \
			--with-pcre-jit \
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
		make -j2 \
	)

.PHONY: install
install: build
	( \
		DST='../pyginx/nginx.exe' ; \
		cp build/nginx-$(NGINX_VERSION)/objs/nginx "$$DST" ; \
		chmod a+x "$$DST" \
	)
