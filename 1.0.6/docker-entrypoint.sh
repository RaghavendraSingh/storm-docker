#!/bin/bash

set -e

# Allow the container to be started with `--user`
if [ "$1" = 'storm' -a "$(id -u)" = '0' ]; then
    chown -R "$STORM_USER" "$STORM_CONF_DIR" "$STORM_DATA_DIR" "$STORM_LOG_DIR"
    exec su-exec "$STORM_USER" "$0" "$@"
fi

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
#cp /etc/collectd/collectd.conf /tmp
#sed -i "s|HOST_NAME|${privateIp}|g" ${COLLECTD_CONF_FILE}
#if [[ ! -z "GRAPHITE_HOST" ]]; then
#	sed -i "s|GRAPHITE_HOST|${GRAPHITE_HOST}|g" ${COLLECTD_CONF_FILE}
#	sed -i "s|GRAPHITE_PORT|${GRAPHITE_PORT}|g" ${COLLECTD_CONF_FILE}
#fi
#rm -f /etc/collectd/collectd.conf
#/usr/sbin/collectdmon -P /var/run/collectd.pid -- -C ${COLLECTD_CONF_FILE}
#collectd -C /tmp/collectd.conf -f &
cores=$(nproc --all)
python ${STORM_CONF_DIR}/yaml_edit.py $STORM_CONF_FILE $cores
# Generate the config only if it doesn't exist
#CONFIG="$STORM_CONF_DIR/storm.yaml"
#if [ ! -f "$CONFIG" ]; then
#    cat << EOF > "$CONFIG"
#storm.zookeeper.servers: [zookeeper]
#nimbus.seeds: [nimbus]
#storm.log.dir: "$STORM_LOG_DIR"
#storm.local.dir: "$STORM_DATA_DIR"
#EOF
#fi

exec "$@"
