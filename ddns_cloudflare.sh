#!/usr/bin/env sh

date -u +"%d/%m/%Y - %H:%M:%S"
echo "Checking IP address..."
IP=$(curl -s http://checkip.amazonaws.com/)
#ZONE_ID=$(echo "$ZONE_ID"|tr -d '\n')
#RECORD_ID=$(echo "$RECORD_ID"|tr -d '\n')
#USER_EMAIL=$(echo "$USER_EMAIL"|tr -d '\n')
#API_KEY=$(echo "$API_KEY"|tr -d '\n')
#DOMAIN_NAME=$(echo "$DOMAIN_NAME"|tr -d '\n')

if [ $? -ne 0 ]
then
    echo "ERROR: Couldn't get IP address."
    exit 1
fi
echo "IP: $IP"


echo "Checking cache file..."
if [ -e $CACHE_FILE ]
then
    LAST_IP=$(cat $CACHE_FILE)
    if [ "$IP" == "$LAST_IP" ]
    then
        echo "No need to update record."
        exit 0
    fi
else
    echo "WARNING: Cache file doesn't exist. It may be created later."
fi


echo "Updating DNS record..."
update=$(curl -X PUT "https://api.cloudflare.com/client/v4/zones/$(echo "$ZONE_ID"|tr -d '\n')/dns_records/$(echo "$RECORD_ID"|tr -d '\n')" \
     -H "X-Auth-Email: $USER_EMAIL" \
     -H "X-Auth-Key: $API_KEY" \
     -H "Content-Type: application/json" \
     --data "{\"id\":\"$RECORD_ID\",\"type\":\"A\",\"name\":\"$DOMAIN_NAME\",\"content\":\"$IP\"}" \
     --http1.0)

if [ $? -ne 0 ] || [[ $update == *"\"success\": false,"* ] ]
then
    echo $update
    echo "ERROR: Couldn't update DNS record."
    exit 2
fi
echo $update
echo "DNS record updated."

echo "Saving IP to local cache..."
echo $IP > $CACHE_FILE
if [ $? -ne 0 ]
then
    echo "WARNING: Couldn't update IP cache."
    exit 0
fi
echo "Local cache updated."
exit 0

