#!/bin/sh

cd ~/devstack
for TOKEN_FORMAT in UUID PKI; do
    for BACKEND in ldap sql; do
        echo "== ${TOKEN_FORMAT} - ${BACKEND} =="
        echo "[+] Unstack // stack..."
        ./unstack.sh

        sed -e "s/^KEYSTONE_TOKEN_FORMAT=.*/KEYSTONE_TOKEN_FORMAT=${TOKEN_FORMAT}/"     \
            -e "s/^KEYSTONE_IDENTITY_BACKEND=.*/KEYSTONE_IDENTITY_BACKEND=${BACKEND}/"  \
            -i localrc
        if [ "${BACKEND}" = "ldap" ]; then
            sed -e "s/^disable_service ldap$/enable_service ldap/" -i localrc
        else
            sed -e "s/^enable_service ldap$/disable_service ldap/" -i localrc
        fi
        ./stack.sh 2>&1 > /dev/null
        if [ "$?" != 0 ]; then
            echo "Stack.sh failed"
            exit 1
        fi

        echo "[+] Create users..."
        PERF_OUTPUT="/tmp/perf-create-users_${TOKEN_FORMAT}_${BACKEND}"
        /usr/bin/time -o ${PERF_OUTPUT} -f "%e" -a ~/bin/perf-create-users.sh
        echo -n "-> "; tail -n 1 ${PERF_OUTPUT}
        sleep 1

        echo "[+] Generate tokens..."
        PERF_OUTPUT="/tmp/perf-gen-tokens_${TOKEN_FORMAT}_${BACKEND}"
        /usr/bin/time -o ${PERF_OUTPUT} -f "%e" -a ~/bin/perf-gen-tokens.sh
        echo -n "-> "; tail -n 1 ${PERF_OUTPUT}
        sleep 1

        echo "[+] Validate tokens..."
        PERF_OUTPUT="/tmp/perf-validate-tokens_${TOKEN_FORMAT}_${BACKEND}"
        /usr/bin/time -o ${PERF_OUTPUT} -f "%e" -a ~/bin/perf-validate-tokens.sh
        echo -n "-> "; tail -n 1 ${PERF_OUTPUT}
        sleep 1
    done
done

