#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

#
# Copyright (c) 2019, Joyent, Inc.
# Copyright 2023 MNX Cloud, Inc.
#

NAME=rabbitmq
TAR = tar
RELEASE_TARBALL=$(NAME)-pkg-$(STAMP).tar.gz

# triton-origin-x86_64-21.4.0
BASE_IMAGE_UUID = 502eeef2-8267-489f-b19c-a206906f57ef
BUILDIMAGE_NAME = $(NAME)
BUILDIMAGE_DESC	= Triton RabbitMQ
BUILDIMAGE_PKGSRC = \
	perl-5.34.0nb3 \
	iodbc-3.52.9 \
	libffi-3.4.2nb1 \
	python27-2.7.18nb8 \
	py27-setuptools-44.1.1 \
	py27-simplejson-3.17.6 \
	erlang14-14.1.4 \
	rabbitmq271-2.7.1
AGENTS		= amon config registrar

ENGBLD_USE_BUILDIMAGE	= true
ENGBLD_REQUIRE		:= $(shell git submodule update --init deps/eng)
include ./deps/eng/tools/mk/Makefile.defs
TOP ?= $(error Unable to access eng.git submodule Makefiles.)

BUILD_PLATFORM  = 20210826T002459Z

ifeq ($(shell uname -s),SunOS)
    include ./deps/eng/tools/mk/Makefile.agent_prebuilt.defs
endif

.PHONY: all
all: sdc-scripts

.PHONY: release
release: all $(RELEASE_TARBALL)

$(RELEASE_TARBALL):
	TAR=$(TAR) bash package.sh $(RELEASE_TARBALL)

publish:
	mkdir -p $(ENGBLD_BITS_DIR)/rabbitmq
	cp $(RELEASE_TARBALL) $(ENGBLD_BITS_DIR)/rabbitmq/$(RELEASE_TARBALL)


sdc-scripts: deps/sdc-scripts/.git

ifeq ($(shell uname -s),SunOS)
    include ./deps/eng/tools/mk/Makefile.agent_prebuilt.targ
endif
include ./deps/eng/tools/mk/Makefile.deps
include ./deps/eng/tools/mk/Makefile.targ
