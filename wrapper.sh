#!/bin/bash

# When this exits, exit all back ground process also.
trap 'kill $(jobs -p)' EXIT

if ! [ -z ${SSL_CERT_FILE+x} ]; then
    use_ssl="yes"
    sed -i "s,CERTFILE,$SSL_CERT_FILE," ${RABBITMQ_HOME}/etc/rabbitmq/ssl.config
fi

if ! [ -z ${SSL_KEY_FILE+x} ]; then
    use_ssl="yes"
    sed -i "s,KEYFILE,$SSL_KEY_FILE," ${RABBITMQ_HOME}/etc/rabbitmq/ssl.config
fi

if ! [ -z ${SSL_CA_FILE+x} ]; then
    use_ssl="yes"
    sed -i "s,CAFILE,$SSL_CA_FILE," ${RABBITMQ_HOME}/etc/rabbitmq/ssl.config
fi

if [ "${use_ssl}" == "yes" ]; then
    echo "Launching RabbitMQ with SSL..."
    echo -e " - SSL_CERT_FILE: $SSL_CERT_FILE\n - SSL_KEY_FILE: $SSL_KEY_FILE\n - SSL_CA_FILE: $SSL_CA_FILE"
    mv ${RABBITMQ_HOME}/etc/rabbitmq/ssl.config \
        ${RABBITMQ_HOME}/etc/rabbitmq/rabbitmq.config
else
    echo "Launching RabbitMQ..."
    mv ${RABBITMQ_HOME}/etc/rabbitmq/standard.config \
        ${RABBITMQ_HOME}/etc/rabbitmq/rabbitmq.config
fi

${RABBITMQ_HOME}/sbin/rabbitmq-server &
until [ -f "${RABBITMQ_HOME}/var/log/rabbitmq/rabbit@${HOSTNAME}.log" ]; do
    sleep 1
done
echo -e "\n\nTailing log output:"
tail -f ${RABBITMQ_HOME}/var/log/rabbitmq/rabbit@${HOSTNAME}.log \
     -f ${RABBITMQ_HOME}/var/log/rabbitmq/rabbit@${HOSTNAME}-sasl.log
