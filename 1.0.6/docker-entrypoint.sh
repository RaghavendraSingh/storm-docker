#!/bin/bash

set -e

# Allow the container to be started with `--user`
#if [ "$1" = 'storm' -a "$(id -u)" = '0' ]; then
#    chown -R "$STORM_USER" "$STORM_CONF_DIR" "$STORM_DATA_DIR" "$STORM_LOG_DIR"
#    exec su "$STORM_USER" "$0" "$@"
#fi

STORM_CONF_FILE=${STORM_CONF_DIR}/storm.yaml
COLLECTD_CONF_FILE=/tmp/collectd.conf
privateIp="$(hostname -i)"
sed -i "s/NIMBUS1/${NIMBUS1}/g" ${STORM_CONF_FILE}
sed -i "s/NIMBUS2/${NIMBUS2}/g" ${STORM_CONF_FILE}
sed -i "s/ZK1/${ZK1}/g" ${STORM_CONF_FILE}
sed -i "s/ZK2/${ZK2}/g" ${STORM_CONF_FILE}
sed -i "s/ZK3/${ZK3}/g" ${STORM_CONF_FILE}
sed -i "s/ZK_PORT/${ZK_PORT}/g" ${STORM_CONF_FILE}
sed -i "s|DATA_DIR|${STORM_DATA_DIR}|g" ${STORM_CONF_FILE}
sed -i "s|LOG_DIR|${STORM_LOG_DIR}|g" ${STORM_CONF_FILE}
cp /etc/collectd/collectd.conf /tmp
sed -i "s|HOST_NAME|${privateIp}|g" ${COLLECTD_CONF_FILE}
collectdPrefix="$(echo $privateIp | sed -r 's/\./-/g')"
nimbusPrefix="$(echo $NIMBUS1 |sed -r 's/\./-/g')"
supervisorPrefix="$(echo $privateIp | sed -r 's/\./-/g')"

if [[ ! -z "GRAPHITE_HOST" ]]; then
	sed -i "s|GRAPHITE_HOST|${GRAPHITE_HOST}|g" ${COLLECTD_CONF_FILE}
	sed -i "s|GRAPHITE_PORT|${GRAPHITE_PORT}|g" ${COLLECTD_CONF_FILE}
        sed -i "s|INSTALL_TAG|$INSTALL_TAG|g" ${COLLECTD_CONF_FILE}
	sed -i "s|HOST_IP|$collectdPrefix|g" ${COLLECTD_CONF_FILE}
	sed -i "s|GRAPHITE_HOST|${GRAPHITE_HOST}|g" ${JMX_CONF_DIR}/*
	sed -i "s|GRAPHITE_PORT|${GRAPHITE_PORT}|g" ${JMX_CONF_DIR}/*
        sed -i "s|SUPERVISOR_IP|$supervisorPrefix|g" ${JMX_CONF_DIR}/*
	sed -i "s|NIMBUS_IP|$nimbusPrefix|g" ${JMX_CONF_DIR}/*
	sed -i "s|INSTALL_TAG|$INSTALL_TAG|g" ${JMX_CONF_DIR}/*
	/etc/init.d/jmxtrans start
        collectd -C /tmp/collectd.conf -f &
fi
#cores=$(nproc --all)
cores=$(($(nproc --all)/4))
if [ $cores -eq 0 ]
   cores=1
python ${STORM_CONF_DIR}/yaml_edit.py $STORM_CONF_FILE $cores
exec "$@"
