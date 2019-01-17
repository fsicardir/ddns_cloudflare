FROM arm32v6/alpine:latest

RUN apk --no-cache add curl

COPY ddns_cloudflare.sh /ddns_cloudflare.sh
COPY crontab /ddns_cloudflare
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh /ddns_cloudflare.sh
RUN /usr/bin/crontab /ddns_cloudflare

CMD ["/entrypoint.sh"]
