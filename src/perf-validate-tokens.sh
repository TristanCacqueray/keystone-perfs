#!/bin/sh

get_id () {
    echo `"$@" | awk '/ id / { print $4 }'`
}
unset OS_SERVICE_TOKEN OS_SERVICE_ENDPOINT
export OS_AUTH_URL=http://localhost:5000/v2.0
export OS_TENANT_NAME=demo
export OS_PASSWORD=nomoresecrete
export OS_USERNAME=admin
ADMIN_TOKEN=$(get_id keystone token-get)
while read USER_TOKEN; do
    curl -H "X-Auth-Token:${ADMIN_TOKEN}" http://0.0.0.0:5000/v2.0/tokens/${USER_TOKEN} \
        2>&1 | grep "issued_at" > /dev/null
    if [ "$?" != 0 ]; then
        echo "Token validation failed"
        break
    fi
done < /tmp/tokens_list.txt

