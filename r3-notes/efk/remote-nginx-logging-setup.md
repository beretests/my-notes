* On NGINX server, install `fluentd-package` (per the instrunctions found at https://docs.fluentd.org/installation/install-by-deb#step-1-install-from-apt-repository)

```
curl -fsSL https://toolbelt.treasuredata.com/sh/install-ubuntu-jammy-fluent-package5-lts.sh | sh
```

Update the `etc/fluent/fluentd.conf` to match the following

```
<source>
  @type tail
  path /var/log/httpd-access.log #...or where you placed your Apache access log
  pos_file /var/log/td-agent/httpd-access.log.pos # This is where you record file position
  tag nginx.access #fluentd tag!
  format nginx # Do you have a custom format? You can write your own regex.
</source>

<match **>
  @type elasticsearch
  logstash_format true
  host <hostname> #(optional; default="localhost")
  port <port> #(optional; default=9200)
  index_name <index name> #(optional; default=fluentd)
  type_name <type name> #(optional; default=fluentd)
</match>
```

* Start fluentd with the configuration

```
fluentd -c fluentd.conf
```

* On Kibana dashboard, create new data view for NGINX logs (with `index_name`)