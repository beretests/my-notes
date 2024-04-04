### Update Docker image
For the version, in `docker-compose.yml`:
```
image: dockerhub.gatineau.credil.org/vanadium-web/vanadium_webapp:<image tag>
```

###### Caching
In `.env`:

```
# cache
REDIS_CACHE_ENABLED=true
REDIS_CACHE_SERVERS=vanadium-redis-cache:6379 
```

###### Redis cache (add this to docker-compose.yml)
```
  redis_cache:
    image: dockerhub.gatineau.credil.org/dockerhub-proxy/library/redis
    container_name: vanadium-redis-cache
    command: redis-server
    volumes:
      - ./tmp/vanadium-redis-cache:/data
    restart: unless-stopped
```
###### CDN
Add this entry to `.env`:
```
# CDN for assets
CDN_HOST=cdn.gatineau.credil.org
```

###### DB Migrate
in the `/opt/docker` directory on host machine:
```
docker compose exec web rails db:migrate
```
