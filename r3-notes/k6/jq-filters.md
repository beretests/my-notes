#### Format k6 JSON results

```
cat k6-results/pacing/pacing.20231003.213353.json | jq . > zz.j
```

### Filter out unique URLs where http_req_failed metric value = 1

```
jq -c 'select(.metric == "http_req_failed" and .type == "Point" and .data.value == 1) | .data.tags.url' zz.j | sort -u
```

### Filter out URLs and staus codes where http_req_failed metric value = 1

```
jq -c 'select(.metric == "http_req_failed" and .type == "Point" and .data.value == 1) | {url: .data.tags.url, status: .data.tags.status}' zz.j 
```