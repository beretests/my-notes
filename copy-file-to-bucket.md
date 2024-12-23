```
scp ~/Downloads/Citizen\ User\ Functionality.html ansiblecontroller:/home/eb/cloudflare-testing-bucket
ssh ansiblecontroller 'aws s3 cp --profile testing /home/eb/cloudflare-testing-bucket/Citizen\ User\ Functionality.html s3://testing-bucket/r3-test-plan.html --content-type "text/html" --endpoint-url https://f945ac38c1c8639d8794bf92c2c8b3f2.r2.cloudflarestorage.com'
```
