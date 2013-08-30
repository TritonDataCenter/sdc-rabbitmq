#!/bin/bash
#
# Copyright (c) 2011, 2012 Joyent Inc. All rights reserved.
#

export PS4='[\D{%FT%TZ}] ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -o xtrace

PATH=/opt/local/bin:/opt/local/sbin:/usr/bin:/usr/sbin

CONFIG_AGENT_LOCAL_MANIFESTS_DIRS=/opt/smartdc/etc/rabbitmq/sapi_manifests

# Include common utility functions (then run the boilerplate)
source /opt/smartdc/sdc-boot/scripts/util.sh
sdc_common_setup

# Cookie to identify this as a SmartDC zone and its role
mkdir -p /var/smartdc/rabbitmq

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
svccfg -s rabbitmq setprop method_context/project=rabbitmq
svcadm refresh rabbitmq

su - rabbitmq -c "/opt/local/sbin/rabbitmqctl -n rabbit@$(zonename) stop"

svcadm disable rabbitmq
# HOME must be set for 'erlexec' (used in rabbitmq-plugins)
export HOME=/root
rabbitmq-plugins enable rabbitmq_management
svcadm enable rabbitmq

# All done, run boilerplate end-of-setup
sdc_setup_complete

exit 0
