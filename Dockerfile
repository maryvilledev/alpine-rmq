FROM        alpine
MAINTAINER  Gonkulator Labs <github.com/gonkulator>
ENV         RABBITMQ_HOME=/srv/rabbitmq_server-3.5.4 \
            PLUGINS_DIR=/srv/rabbitmq_server-3.5.4/plugins \
            ENABLED_PLUGINS_FILE=/srv/rabbitmq_server-3.5.4/etc/rabbitmq/enabled_plugins \
            RABBITMQ_MNESIA_BASE=/var/lib/rabbitmq
COPY        ssl.config /srv/rabbitmq_server-3.5.4/etc/rabbitmq/
COPY        standard.config /srv/rabbitmq_server-3.5.4/etc/rabbitmq/
COPY        wrapper.sh /usr/bin/wrapper
ADD         https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_5_4/rabbitmq-server-generic-unix-3.5.4.tar.gz /srv/rabbitmq-server-generic-unix-3.5.4.tar.gz
RUN         chmod a+x /usr/bin/wrapper && apk add --update curl tar gzip bash && \
            apk add erlang erlang erlang-mnesia erlang-public-key erlang-crypto erlang-ssl \
                erlang-sasl erlang-asn1 erlang-inets erlang-os-mon erlang-xmerl erlang-eldap \
                --update-cache --allow-untrusted \
                -X http://dl-4.alpinelinux.org/alpine/edge/main/ && \
            cd /srv && \
            tar -xzvf rabbitmq-server-generic-unix-3.5.4.tar.gz && \
            rm -f rabbitmq-server-generic-unix-3.5.4.tar.gz && \
            touch /srv/rabbitmq_server-3.5.4/etc/rabbitmq/enabled_plugins && \
            /srv/rabbitmq_server-3.5.4/sbin/rabbitmq-plugins enable --offline rabbitmq_management && \
            apk del --purge tar gzip
EXPOSE      5671/tcp 5672/tcp 15672/tcp 15671/tcp
VOLUME      /var/lib/rabbitmq
CMD         /usr/bin/wrapper