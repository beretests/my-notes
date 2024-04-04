Culled from [Optimizing COnfiguration for Max Performance](https://www.chatwoot.com/docs/self-hosted/deployment/performance/optimizing-configurations/)

Puma is a popular web server for Ruby on Rails applications, and it uses multiple workers and threads to handle incoming requests. Each Worker runs its own instance of the application, and each thread within a worker can handle a single request at a time.

##### Workers
When the Puma server receives a request, it is assigned to a worker process in a round-robin fashion. Once a worker receives a request, it assigns the request to an available thread within its process. Each thread then handles the request, including any required database queries, calculations, and other processing tasks. Using multiple worker processes allows Puma to handle multiple requests concurrently without blocking other requests or causing a bottleneck.

###### Configuring number of workers
The `WEB_CONCURRENCY` environment variable configures the number of workers in Puma. Use number of workers that matches or is slightly less than the number of available CPU cores to avoid competition for CPU time, which can lead to performance issues.

##### Threads
Each Puma thread is a lightweight execution context that can handle a single request at a time. When a worker process receives a request, it is assigned to an available thread within that process. Each thread then handles the request, including any required database queries, calculations, and other processing tasks.
The `RAILS_MIN_THREADS` and `RAILS_MAX_THREADS` environment variables configure the number of threads per worker in Puma to increase concurrency and performance.