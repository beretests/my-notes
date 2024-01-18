### Copy local file to container

```
docker container cp /home/ansible-controller/kpq43xu0it3qbykncd5ghmewqehx docker-web-1:/opt/vanadium-web/storage/kp/q4
```

### Copy files from container to local path

```
docker container cp docker-web-1:/opt/vanadium-web/storage/kp/q4/kpq43xu0it3qbykncd5ghmewqehx .
# . means copy to current working directory
```