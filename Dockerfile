FROM        alpine:latest
MAINTAINER  Maryville Technologies <github.com/maryvilledev>

ENV         RABBITMQ_VERSION=3.6.6 \
            RABBITMQ_AUTOCLUSTER_PLUGIN_VERSION=0.6.1
ENV         RABBITMQ_HOME=/srv/rabbitmq_server-${RABBITMQ_VERSION} \
            PLUGINS_DIR=/srv/rabbitmq_server-${RABBITMQ_VERSION}/plugins \
            ENABLED_PLUGINS_FILE=/srv/rabbitmq_server-${RABBITMQ_VERSION}/etc/rabbitmq/enabled_plugins \
            RABBITMQ_MNESIA_BASE=/var/lib/rabbitmq \
            ERLANG_VERSION=18.3.2-r0
ENV         PATH=$PATH:$RABBITMQ_HOME/sbin

COPY        ssl.config /srv/rabbitmq_server-${RABBITMQ_VERSION}/etc/rabbitmq/
COPY        standard.config /srv/rabbitmq_server-${RABBITMQ_VERSION}/etc/rabbitmq/
COPY        wrapper.sh /usr/bin/wrapper

EXPOSE      5671/tcp 5672/tcp 15672/tcp 15671/tcp
VOLUME      /var/lib/rabbitmq
CMD         ["/usr/bin/wrapper"]

RUN         for p in erlang erlang-mnesia erlang-public-key erlang-crypto erlang-ssl erlang-sasl \
                erlang-asn1 erlang-inets erlang-os-mon erlang-xmerl erlang-eldap erlang-syntax-tools;do \
                ERLS="$ERLS $p=$ERLANG_VERSION"; done && \
            chmod a+x /usr/bin/wrapper && \
            apk add --update curl bash $ERLS && \
            cd /srv && \
            rmq_zip_url=https://github.com/rabbitmq/rabbitmq-server/releases/download && \
                rmq_zip_url=${rmq_zip_url}/rabbitmq_v$(echo $RABBITMQ_VERSION | tr '.' '_') && \
                rmq_zip_url=${rmq_zip_url}/rabbitmq-server-generic-unix-${RABBITMQ_VERSION}.tar.xz && \
            curl -L -o /srv/rmq.tar.xz $rmq_zip_url && \
            tar -x -f rmq.tar.xz && rm -f rmq.tar.xz && \
            touch /srv/rabbitmq_server-${RABBITMQ_VERSION}/etc/rabbitmq/enabled_plugins && \
            rabbitmq-plugins enable --offline rabbitmq_management && \
            rmq_ac_url=https://github.com/aweber/rabbitmq-autocluster/releases/download && \
                rmq_ac_url=${rmq_ac_url}/${RABBITMQ_AUTOCLUSTER_PLUGIN_VERSION} && \
                rmq_ac_url=${rmq_ac_url}/autocluster-${RABBITMQ_AUTOCLUSTER_PLUGIN_VERSION}.tgz && \
            curl -L -o /tmp/autocluster-${RABBITMQ_AUTOCLUSTER_PLUGIN_VERSION}.tgz $rmq_ac_url && \
            tar -x -C ${RABBITMQ_HOME} -f /tmp/autocluster-${RABBITMQ_AUTOCLUSTER_PLUGIN_VERSION}.tgz && \
            rm -Rf /var/cache/apk/*  /tmp/* && \
            ln -sf $RABBITMQ_HOME /rabbitmq
