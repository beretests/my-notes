```
docker ps --quiet --all | xargs docker rm -f
docker image ls --quiet | xargs docker rmi -f
docker system prune --all
```