FROM        alpine
MAINTAINER  Cole Brumley <github.com/colebrumley>
ENV         RABBITMQ_HOME=/srv/rabbitmq_server-3.5.3 \
            PLUGINS_DIR=/srv/rabbitmq_server-3.5.3/plugins \
            ENABLED_PLUGINS_FILE=/srv/rabbitmq_server-3.5.3/etc/rabbitmq/enabled_plugins \
            RABBITMQ_MNESIA_BASE=/var/lib/rabbitmq
ADD         https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_5_3/rabbitmq-server-generic-unix-3.5.3.tar.gz /srv/rabbitmq-server-generic-unix-3.5.3.tar.gz
COPY        wrapper.sh /usr/bin/wrapper
RUN         chmod a+x /usr/bin/wrapper && apk add --update tar gzip bash && \
            apk add erlang erlang erlang-mnesia erlang-public-key erlang-crypto erlang-ssl \
                erlang-sasl erlang-asn1 erlang-inets erlang-os-mon erlang-xmerl erlang-eldap \
                --update-cache --allow-untrusted \
                --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ && \
            cd /srv && \
            tar -xzvf rabbitmq-server-generic-unix-3.5.3.tar.gz && \
            rm -f rabbitmq-server-generic-unix-3.5.3.tar.gz && \
            touch rabbitmq_server-3.5.3/etc/rabbitmq/enabled_plugins && \
            rabbitmq_server-3.5.3/sbin/rabbitmq-plugins enable --offline rabbitmq_management && \
            apk del --purge tar gzip
COPY        ssl.config /srv/rabbitmq_server-3.5.3/etc/rabbitmq/
COPY        standard.config /srv/rabbitmq_server-3.5.3/etc/rabbitmq/
EXPOSE      5671/tcp 5672/tcp 15672/tcp
VOLUME      /var/lib/rabbitmq
CMD         /usr/bin/wrapper