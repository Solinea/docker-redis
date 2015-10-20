# vim:set ft=dockerfile:

# Adapted from https://github.com/docker-library/redis/tree/master/3.0

FROM solinea/debian:jessie

MAINTAINER Luke Heidecke <luke@solinea.com>

RUN pkgList=' \
    ca-certificates \
    curl \
  ' \
  && apt-get update -y -q -q \
  && apt-get install --no-install-recommends -y -q $pkgList \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV REDIS_VERSION 3.0.4
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz
ENV REDIS_PORT 6379
ENV REDIS_CONFIG_DIR /etc/redis
ENV REDIS_DATA_DIR /var/lib/redis

RUN buildDeps=' \
    build-essential \
    tcl8.5 \
  ' \
  && set -x \
  && apt-get update -y -q -q \
  && apt-get install --no-install-recommends -y -q $buildDeps \
  && mkdir -p /usr/src/redis \
  && curl -sSL "$REDIS_DOWNLOAD_URL" -o redis.tar.gz \
  && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
  && rm redis.tar.gz \
  && make -C /usr/src/redis \
  && make -C /usr/src/redis test \
  && make -C /usr/src/redis install \
  && rm -r /usr/src/redis \
  && apt-get purge -y --auto-remove $buildDeps \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# create the redis user
RUN groupadd -r redis && useradd -r -d /var/redis -g redis redis

# create config directory
RUN mkdir $REDIS_CONFIG_DIR && chown redis:redis $REDIS_CONFIG_DIR
VOLUME $REDIS_CONFIG_DIR

# create data directory
RUN mkdir $REDIS_DATA_DIR && chown redis:redis $REDIS_DATA_DIR
VOLUME $REDIS_DATA_DIR
WORKDIR $REDIS_DATA_DIR

COPY docker-entrypoint.sh /entrypoint.sh

USER redis

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE $REDIS_PORT
CMD [ ]
