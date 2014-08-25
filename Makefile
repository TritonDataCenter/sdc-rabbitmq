#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

#
# Copyright (c) 2014, Joyent, Inc.
#

NAME=rabbitmq

ifeq ($(VERSION), "")
    @echo "Use gmake"
endif

TAR = tar

ifeq ($(TIMESTAMP),)
    TIMESTAMP=$(shell date -u "+%Y%m%dT%H%M%SZ")
endif

RABBITMQ_PUBLISH_VERSION := $(shell git symbolic-ref HEAD | \
      awk -F / '{print $$3}')-$(TIMESTAMP)-g$(shell \
                git describe --all --long | awk -F '-g' '{print $$NF}')

RELEASE_TARBALL=rabbitmq-pkg-$(RABBITMQ_PUBLISH_VERSION).tar.bz2

.PHONY: all

all: sdc-scripts

release: $(RELEASE_TARBALL)

$(RELEASE_TARBALL):
	TAR=$(TAR) bash package.sh $(RELEASE_TARBALL)

publish:
	@if [[ -z "$(BITS_DIR)" ]]; then \
      echo "error: 'BITS_DIR' must be set for 'publish' target"; \
      exit 1; \
    fi
	mkdir -p $(BITS_DIR)/rabbitmq
	cp $(RELEASE_TARBALL) $(BITS_DIR)/rabbitmq/$(RELEASE_TARBALL)

clean:
	rm -fr rabbitmq-pkg-*.tar.bz2

sdc-scripts: deps/sdc-scripts/.git
