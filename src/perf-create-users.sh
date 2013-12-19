#!/bin/sh

export OS_SERVICE_TOKEN=ADMIN
export OS_SERVICE_ENDPOINT=http://localhost:35357/v2.0
for i in $(seq 100); do
    keystone user-create --name perf_testuser_$(printf "%04d" $i) \
                         --tenant demo --pass demopass 2>&1 > /dev/null
    if [ "$?" != 0 ]; then
        echo "User creation failed"
        break
    fi
done

