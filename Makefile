#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

#
# Copyright (c) 2019, Joyent, Inc.
#

NAME=rabbitmq
TAR = tar
RELEASE_TARBALL=$(NAME)-pkg-$(STAMP).tar.gz

BASE_IMAGE_UUID = fd2cc906-8938-11e3-beab-4359c665ac99
BUILDIMAGE_NAME = $(NAME)
BUILDIMAGE_DESC	= SDC RabbitMQ
BUILDIMAGE_PKGSRC = \
	perl-5.14.2nb3 \
	iodbc-3.52.7 \
	libffi-3.0.9nb1 \
	python27-2.7.2nb2 \
	py27-setuptools-0.6c11nb1 \
	py27-simplejson-2.1.1 \
	erlang-14.1.4nb1 \
	rabbitmq-2.7.1
AGENTS		= amon config registrar

ENGBLD_USE_BUILDIMAGE	= true
ENGBLD_REQUIRE		:= $(shell git submodule update --init deps/eng)
include ./deps/eng/tools/mk/Makefile.defs
TOP ?= $(error Unable to access eng.git submodule Makefiles.)

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
