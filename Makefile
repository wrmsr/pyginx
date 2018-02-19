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
	-rm -rf .venv-install
	-rm -rf build
	-rm -rf dist
	-rm -rf pyginx.egg-info
	-rm -rf wheelhouse

	find pyginx \
		-name '*.pyc' -delete -or \
		-name '*.pyo' -delete -or \
		-name '__pycache__' -delete -or \
		-name '*.exe' -delete

	(cd nginx && make clean)

.PHONY: brew
brew:
	brew install $(PYENV_BREW_DEPS)

.PHONY: venv
venv:
	if [ ! -d .venv ] ; then \
		set -e ; \
		\
		if [ ! -z "$$MANYLINUX" ] ; then \
			/opt/python/cp36-cp36m/bin/python -m virtualenv .venv ; \
		else \
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
		fi ; \
		\
		.venv/bin/pip install --upgrade pip setuptools ; \
		.venv/bin/pip install $(PIP_ARGS) -r requirements.txt ; \
	fi

.PHONY: build
build: venv
	.venv/bin/python setup.py build

.PHONY: test
test: build
	.venv/bin/python -m unittest discover pyginx '*_test.py'

.PHONY: dist
dist: build
	.venv/bin/python setup.py bdist_wheel

.PHONY: test_install
test_install: dist
	rm -rf .venv-install

	if [ ! -z "$$MANYLINUX" ] ; then \
		/opt/python/cp36-cp36m/bin/python -m virtualenv .venv-install ; \
	elif [ "$$(python --version)" == "Python $(PYTHON_VERSION)" ] ; then \
		virtualenv .venv-install ; \
	else \
		virtualenv -p $(PYENV_ROOT)/versions/$(PYTHON_VERSION)/bin/python .venv-install ; \
	fi

	.venv-install/bin/pip install $(PIP_ARGS) -r requirements.txt

	.venv-install/bin/python -m wheel install $(PIP_ARGS) $$(find dist/*.whl)

	cd .venv-install && bin/python -c 'import os, pkg_resources; exit(0 if os.path.exists(pkg_resources.resource_filename("pyginx", "nginx.exe")) else 1)'

.PHONY: upload
upload: test_install
	.venv/bin/python setup.py bdist_wheel upload

.PHONY: docker
docker:
	docker build -t wrmsr/pyginx .

.PHONY: docker_bash
docker_bash: docker
	docker run -v "$$(pwd):/pyginx" -it wrmsr/pyginx bash

.PHONY: docker_build
docker_build:
	docker run -v "$$(pwd):/pyginx" -it wrmsr/pyginx bash -c 'cd /pyginx && make'

.PHONY: docker_test
docker_test: docker_build
	docker run -v "$$(pwd):/pyginx" -it wrmsr/pyginx .venv/bin/python -m unittest discover pyginx '*_test.py'
