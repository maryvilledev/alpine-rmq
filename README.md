# Alpine Linux RabbitMQ Docker image
Many other RabbitMQ Docker images are [huge](https://imagelayers.io/?images=rabbitmq:latest,frodenas%2Frabbitmq:latest,tutum%2Frabbitmq:latest).  Instead of using the bloated Ubuntu or Fedora images as a base, this image uses the 5MB Alpine Linux base image.  Alpine lets us run RabbitMQ 3.6.0 on Erlang 18.1 in only **27MB**!

### Usage
The wrapper script starts RabbitMQ (with management plugin enabled), tails the log, and configures listeners on the standard ports:
  - `5671/tcp`: Listening port when SSL is enabled
  - `5672/tcp`: Non-SSL default listening port
  - `15671/tcp`: SSL GUI listening port
  - `15672/tcp`: Non-SSL GUI listening port

RabbitMQ's data is persisted to a volume at `/var/lib/rabbitmq`.

To enable SSL set the `$SSL_CERT_FILE`, `$SSL_KEY_FILE`, and `$SSL_CA_FILE` environment variables.  The wrapper script will use the same certs for GUI SSL access as for AMQPS access.


*Example:*
```
# Run with TLS enabled
docker run -it \
  --name rabbitmq \
  -p 5671:5671 \
  -p 15671:15671 \
  -e SSL_CERT_FILE=/ssl/cert/cert.pem \
  -e SSL_KEY_FILE=/ssl/cert/key.pem \
  -e SSL_CA_FILE=/ssl/CA/cacert.pem \
  gonkulatorlabs/rabbitmq
```

```
# Run without TLS
docker run -d \
  --name rabbitmq \
  -p 5672:5672 \
  -p 15672:15672 \
  gonkulatorlabs/rabbitmq
```

### Customizing
To set a custom config, ditch the wrapper script and call `rabbitmq-server` directly.  Place the custom config in `/srv/rabbitmq_server-3.6.0/etc/rabbitmq/`.

### Fair Warning!
Alpine's Erlang packages are in its `edge` (testing) repo, if that bothers you then don't use this image!
