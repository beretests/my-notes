#### 1. "Error on ingesting samples with different value but same timestamp"

```
Mar 19 22:07:45 portage grafana-agent[794013]: ts=2024-03-19T22:07:45.094625219Z caller=dedupe.go:112 agent=prometheus instance=90a37bd9f003fd136063d725fc12f649 component=remote level=error remote_name=90a37b-d86a9c url=https://prometheus-prod-32-prod-ca-east-0.grafana.net/api/prom/push msg="non-recoverable error" count=5 exemplarCount=0 err="server returned HTTP status 400 Bad Request: failed pushing to ingester ingester-zone-c-0: user=1474209: the sample has been rejected because another sample with the same timestamp, but a different value, has already been ingested (err-mimir-sample-duplicate-timestamp). The affected sample has timestamp 2024-03-19T22:07:32.227Z and is from series scrape_duration_seconds{host=\"portage-qa-qpp1\", instance=\"localhost:9100\", job=\"node\"} (sampled 1/10)"
Mar 19 22:08:45 portage grafana-agent[794013]: ts=2024-03-19T22:08:45.116387381Z caller=dedupe.go:112 agent=prometheus instance=90a37bd9f003fd136063d725fc12f649 component=remote level=error remote_name=90a37b-d86a9c url=https://prometheus-prod-32-prod-ca-east-0.grafana.net/api/prom/push msg="non-recoverable error" count=5 exemplarCount=0 err="server returned HTTP status 400 Bad Request: failed pushing to ingester ingester-zone-c-0: user=1474209: the sample has been rejected because another sample with the same timestamp, but a different value, has already been ingested (err-mimir-sample-duplicate-timestamp). The affected sample has timestamp 2024-03-19T22:08:32.227Z and is from series scrape_duration_seconds{host=\"portage-qa-qpp1\", instance=\"localhost:9100\", job=\"node\"} (sampled 1/10)"
Mar 19 22:09:45 portage grafana-agent[794013]: ts=2024-03-19T22:09:45.135546458Z caller=dedupe.go:112 agent=prometheus instance=90a37bd9f003fd136063d725fc12f649 component=remote level=error remote_name=90a37b-d86a9c url=https://prometheus-prod-32-prod-ca-east-0.grafana.net/api/prom/push msg="non-recoverable error" count=5 exemplarCount=0 err="server returned HTTP status 400 Bad Request: failed pushing to ingester ingester-zone-a-0: user=1474209: the sample has been rejected because another sample with the same timestamp, but a different value, has already been ingested (err-mimir-sample-duplicate-timestamp). The affected sample has timestamp 2024-03-19T22:09:32.227Z and is from series scrape_duration_seconds{host=\"portage-qa-qpp1\", instance=\"localhost:9100\", job=\"node\"} (sampled 1/10)"

**Resolution:** Ensured all metrics and logs being sent had unique labels
**More Info:** https://promlabs.com/blog/2022/12/15/understanding-duplicate-samples-and-out-of-order-timestamp-errors-in-prometheus/


#### 2. Agent not connecting to Grafana Cloud

```
Mar 19 22:29:29 portage grafana-agent[794013]: ts=2024-03-19T22:29:29.848158168Z caller=cleaner.go:203 level=warn agent=prometheus component=cleaner msg="unable to find segment mtime of WAL" name=/var/lib/grafana-agent/.cache err="unable to open WAL: open /var/lib/grafana-agent/.cache/wal: no such file or directory"
```
