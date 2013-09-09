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
mkdir -p ${tmpdir}/root/opt/smartdc/boot/scripts

cp ${ROOT}/rabbitmq.xml ${tmpdir}/root/opt/smartdc/etc/rabbitmq/rabbitmq.xml
cp ${ROOT}/rabbitmq-env.conf ${tmpdir}/root/opt/local/etc/rabbitmq/rabbitmq-env.conf
cp ${ROOT}/rabbitmq.config ${tmpdir}/root/opt/local/etc/rabbitmq/rabbitmq.config
cp -r ${ROOT}/sapi_manifests ${tmpdir}/root/opt/smartdc/etc/rabbitmq/sapi_manifests

# update/create sdc-scripts
git submodule update --init ${ROOT}/deps/sdc-scripts

# copy in boot scripts
mkdir -p ${tmpdir}/root/opt/smartdc/boot
cp -R ${ROOT}/deps/sdc-scripts/* ${tmpdir}/root/opt/smartdc/boot/
cp -R ${ROOT}/boot/* ${tmpdir}/root/opt/smartdc/boot/

(cd ${tmpdir}; tar -jcf ${ROOT}/${RELEASE_TARBALL} root site)

rm -rf ${tmpdir}
