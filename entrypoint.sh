#!/bin/sh

/ddns_cloudflare.sh
# start cron
/usr/sbin/crond -f -l 8
