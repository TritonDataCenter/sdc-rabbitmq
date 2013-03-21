#!/usr/bin/bash

set -o xtrace
set -o errexit

RELEASE_TARBALL=$1
echo "Building ${RELEASE_TARBALL}"

ROOT=$(pwd)

tmpdir="/tmp/rabbitmq.$$"
mkdir -p ${tmpdir}/root/opt/smartdc/etc/rabbitmq
mkdir -p ${tmpdir}/root/opt/local/etc/rabbitmq
mkdir -p ${tmpdir}/site

cp ${ROOT}/rabbitmq.xml ${tmpdir}/root/opt/smartdc/etc/rabbitmq/rabbitmq.xml
cp ${ROOT}/rabbitmq-env.conf ${tmpdir}/root/opt/local/etc/rabbitmq/rabbitmq-env.conf
cp ${ROOT}/rabbitmq.config ${tmpdir}/root/opt/local/etc/rabbitmq/rabbitmq.config

(cd ${tmpdir}; tar -jcf ${ROOT}/${RELEASE_TARBALL} root site)

rm -rf ${tmpdir}
