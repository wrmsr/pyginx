SHELL:=/bin/bash

PYTHON_VERSION:=3.6.3

PYENV_ROOT:=$(shell if [ -z "$${PYENV_ROOT}" ]; then echo "$${HOME}/.pyenv" ; else echo "$${PYENV_ROOT%/}" ; fi)
PYENV_BIN:=$(shell if [ -f "$${HOME}/.pyenv/bin/pyenv" ] ; then echo "$${HOME}/.pyenv/bin/pyenv" ; else echo pyenv ; fi)

PIP_ARGS:=

all: clean build test test_install

.PHONY: clean
clean:
	-rm -rf .cache
	-rm -rf .venv
	-rm -rf build
	-rm -rf dist
	-rm -rf pyginx.egg-info
	find pyginx \
		-name '*.pyc' -delete -or \
		-name '*.pyo' -delete -or \
		-name '__pycache__' -delete -or \
		-name '*.exe' -delete

.PHONY: brew
brew:
	brew install $(PYENV_BREW_DEPS)

.PHONY: venv
venv:
	if [ ! -d .venv ] ; then \
		set -e ; \
		\
		PYENV_INSTALL_DIR="$(PYTHON_VERSION)" ; \
		PYENV_INSTALL_FLAGS="-s -v"; \
		if [ ! -z "$$DEBUG" ] ; then \
			PYENV_INSTALL_DIR="$$PYENV_INSTALL_DIR"-debug ; \
			PYENV_INSTALL_FLAGS="$$PYENV_INSTALL_FLAGS -g" ; \
		fi ; \
		if [ "$$(uname)" = "Darwin" ] && command -v brew ; then \
			PYENV_CFLAGS="" ; \
			PYENV_LDFLAGS="" ; \
			for DEP in $(PYENV_BREW_DEPS); do \
				PYENV_CFLAGS="-I$$(brew --prefix "$$DEP")/include $$PYENV_CFLAGS" ; \
				PYENV_LDFLAGS="-L$$(brew --prefix "$$DEP")/lib $$PYENV_LDFLAGS" ; \
			done ; \
			CFLAGS="$$PYENV_CFLAGS $$CFLAGS" \
			LDFLAGS="$$PYENV_LDFLAGS $$LDFLAGS" \
			PKG_CONFIG_PATH="$$(brew --prefix openssl)/lib/pkgconfig:$PKG_CONFIG_PATH" \
			$(PYENV_BIN) install $$PYENV_INSTALL_FLAGS $(PYTHON_VERSION) ; \
		else \
			$(PYENV_BIN) install $$PYENV_INSTALL_FLAGS $(PYTHON_VERSION) ; \
		fi ; \
		virtualenv -p "$(PYENV_ROOT)/versions/$$PYENV_INSTALL_DIR/bin/python" .venv ; \
		\
		.venv/bin/pip install --upgrade pip setuptools ; \
		.venv/bin/pip install $(PIP_ARGS) -r requirements.txt ; \
	fi

.PHONY: bundled
bundled: venv
	if [ ! -f pyginx/nginx.exe ] ; then \
		(set -e && source .venv/bin/activate && cd nginx && make clean install) ; \
	fi

.PHONY: build
build: bundled

.PHONY: test
test: build
	.venv/bin/python -m unittest discover pyginx '*_test.py'

.PHONY: dist
dist: build
	$(eval DIST_BUILD_PYTHON:=$(realpath .venv/bin/python))

	"$(DIST_BUILD_PYTHON)" setup.py bdist_wheel
