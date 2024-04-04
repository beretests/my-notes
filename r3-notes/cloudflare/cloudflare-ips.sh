#!/bin/bash

# Function to fetch IP addresses from Cloudflare API
fetch_cloudflare_ips() {
    curl -s -X GET "https://api.cloudflare.com/client/v4/ips" -H "Authorization: Bearer $API_TOKEN" | jq -r '.result.ipv4_cidrs[]' > cloudflare_ips.txt
    curl -s -X GET "https://api.cloudflare.com/client/v4/ips" -H "Authorization: Bearer $API_TOKEN" | jq -r '.result.ipv6_cidrs[]' >> cloudflare_ips.txt
}

# Function to generate the configuration file
generate_config_file() {
    echo "# Cloudflare IP ranges" > /etc/nginx/conf.d/nginx-cloudflare-realip.conf
    while IFS= read -r line; do
        echo "set_real_ip_from $line;" >> /etc/nginx/conf.d/nginx-cloudflare-realip.conf
    done < cloudflare_ips.txt

    echo "" >> /etc/nginx/conf.d/nginx-cloudflare-realip.conf
    echo "# use any of the following two" >> /etc/nginx/conf.d/nginx-cloudflare-realip.conf
    echo "real_ip_header CF-Connecting-IP;" >> /etc/nginx/conf.d/nginx-cloudflare-realip.conf
    # Uncomment the line below if you want to use X-Forwarded-For header
    # echo "real_ip_header X-Forwarded-For;" >> /etc/nginx/conf.d/nginx-cloudflare-realip.conf
}

# Fetch IPs and generate config file
fetch_cloudflare_ips
generate_config_file

echo "Configuration file generated: /etc/nginx/conf.d/nginx-cloudflare-realip.conf"
