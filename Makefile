SHELL:=/bin/bash

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
		virtualenv .venv ; \
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
	.venv/bin/pytest -v pyginx

.PHONY: dist
dist: build
	$(eval DIST_BUILD_PYTHON:=$(realpath .venv/bin/python))

	git describe --match=NeVeRmAtCh --always --abbrev=40 --dirty > "$(DIST_BUILD_DIR)/pyginx/.revision"

	"$(DIST_BUILD_PYTHON)" setup.py bdist_wheel
