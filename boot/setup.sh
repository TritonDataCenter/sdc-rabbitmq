#!/bin/bash
# -*- mode: shell-script; fill-column: 80; -*-
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

#
# Copyright (c) 2014, Joyent, Inc.
#

export PS4='[\D{%FT%TZ}] ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -o xtrace

PATH=/opt/local/bin:/opt/local/sbin:/usr/bin:/usr/sbin

role=rabbitmq
CONFIG_AGENT_LOCAL_MANIFESTS_DIRS=/opt/smartdc/etc/$role/sapi_manifests

# Include common utility functions (then run the boilerplate)
source /opt/smartdc/boot/lib/util.sh
sdc_common_setup

# Cookie to identify this as a SmartDC zone and its role
mkdir -p /var/smartdc/$role

echo "Finishing setup of rabbitmq zone"

#
# Erlang prior to R15B always binds to CPUs by default. To deal with
# this we need to explicitly tell Erlang not to bind to CPUs.
#
echo 'SERVER_ERL_ARGS="$SERVER_ERL_ARGS +sbt u"' \
    >> /opt/local/etc/rabbitmq/rabbitmq-env.conf

# Setup .erlang.cookie symlink
if [[ ! -L /root/.erlang.cookie ]]; then
	ln -s /var/db/rabbitmq/.erlang.cookie /root/.erlang.cookie
fi

manifest=/opt/smartdc/etc/rabbitmq/rabbitmq.xml
if [[ ! -f ${manifest} ]]; then
    fatal "No SMF manifest found at ${manifest}"
fi

echo "Importing SMF manifest"
svccfg import ${manifest}

projadd -c "Rabbitmq settings" -U rabbitmq -G rabbitmq \
    -K "process.max-file-descriptor=(basic,65535,deny)" \
    rabbitmq
svccfg -s $role setprop method_context/project=rabbitmq
svcadm refresh $role

su - rabbitmq -c "/opt/local/sbin/rabbitmqctl -n rabbit@$(zonename) stop"

# Swap in the replacement for rabbitmq-server which clears /var/db/rabbitmq
# on startup (HEAD-2187).
if [[ -f /opt/local/sbin/rabbitmq-server.sdc ]]; then
    cp /opt/local/sbin/rabbitmq-server /opt/local/sbin/rabbitmq-server.ori
    cp /opt/local/sbin/rabbitmq-server.sdc /opt/local/sbin/rabbitmq-server
fi

svcadm disable $role
# HOME must be set for 'erlexec' (used in rabbitmq-plugins)
export HOME=/root
rabbitmq-plugins enable rabbitmq_management
svcadm enable $role

sdc_log_rotation_add amon-agent /var/svc/log/*amon-agent*.log 1g
sdc_log_rotation_add config-agent /var/svc/log/*config-agent*.log 1g
sdc_log_rotation_add registrar /var/svc/log/*registrar*.log 1g
sdc_log_rotation_add $role /var/svc/log/*$role*.log 1g
sdc_log_rotation_setup_end

# All done, run boilerplate end-of-setup
sdc_setup_complete

exit 0
