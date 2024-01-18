- install fluentd from docker compose
- `fluent.conf`

```
<source>
    @type forward
    port 24224
    bind 0.0.0.0
</source>

<match docker.**>
    @type file
    path /path/to/log/docker #where to write logs
    format json
    time_slice_format %Y&m%d
    time_slice_wait 10m
    time_format %Y%m%dT%H%M%S%z
</match>
```

- specify logging driver for container in docker compose

```
services:
    postgres:
        image: postgres 14
        logging:
            driver: fluentd
            options:
                fluentd-address: localhost:24224
                tag: docker.{{.Name}}

```

- verify logging

- set up rotation of log file

- log all queries `docker run -d --name some-postgres postgres -c log_statement=all`

```
# for docker compose
version: "2.2"
services:
  db:
    image: postgres:12-alpine
    command: ["postgres", "-c", "log_statement=all"]
```