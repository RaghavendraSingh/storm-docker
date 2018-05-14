FROM openjdk:8-jre-alpine

# Install required packages
RUN apk add --no-cache \
    bash \
    python \
    su-exec \
    py-pip  \
    collectd
RUN pip install pyyaml

ENV STORM_USER=storm \
    STORM_CONF_DIR=/conf \
    STORM_DATA_DIR=/data \
    STORM_LOG_DIR=/logs

# Add a user and make dirs
RUN set -ex; \
    adduser -D "$STORM_USER"; \
    mkdir -p "$STORM_CONF_DIR" "$STORM_DATA_DIR" "$STORM_LOG_DIR"; \
    chown -R "$STORM_USER:$STORM_USER" "$STORM_CONF_DIR" "$STORM_DATA_DIR" "$STORM_LOG_DIR"``
COPY storm.yaml $STORM_CONF_DIR/
RUN mkdir -p /etc/collectd/
COPY yaml_edit.py $STORM_CONF_DIR/
COPY collectd.conf /etc/collectd/
ARG GPG_KEY=ACEFE18DD2322E1E84587A148DE03962E80B8FFD
ARG DISTRO_NAME=inmobi-apache-storm-1.1.0.1
COPY apache-storm-bin-1.1.0.1.tar.gz /
RUN tar -xzf apache-storm-bin-1.1.0.1.tar.gz
RUN chown -R "$STORM_USER:$STORM_USER" "$DISTRO_NAME"
# Download Apache Storm, verify its PGP signature, untar and clean up
WORKDIR $DISTRO_NAME

ENV PATH $PATH:/$DISTRO_NAME/bin

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
