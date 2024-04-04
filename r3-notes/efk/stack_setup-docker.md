```
# install docker
apt install docker.io

# install efk
docker pull docker.elastic.co/elasticsearch/elasticsearch:8.11.1
docker pull docker.elastic.co/kibana/kibana:8.11.1
docker pull fluent/fluentd:v1.16.3-debian-amd64-1.0

# create docker network
docker network create efk-network

# run elasticsearch
docker run -d --name elasticsearch --net efk-network -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elastc
```