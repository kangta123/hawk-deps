#!/bin/sh

if [[ ${SSH} == 1 ]]; then
  echo "root:${SSHPASSWORD}" | chpasswd
  /usr/sbin/sshd -D &
fi


healthz="127.0.0.1:15020/healthz/ready"
if [ -n "${HAWK_GATEWAY}" ];then
    for i in $(seq 30); do
        echo "Waiting network connection available. ${i}"
        curl -i ${healthz}

        if [[ $? -eq "0" ]]; then
            s=`curl -s -w "%{http_code}" -H "Connection: close" ${healthz}`
            if [ $s -eq "200" ];then
              echo "connected to hawk gateway"
              break;
            fi
        fi
        sleep 1
    done

    curl -s -o out.sh -H "Connection: close" "http://${HAWK_GATEWAY}/container/file?serviceName=${SERVICE_NAME}&namespace=${POD_NAMESPACE}"

    sh out.sh

else
  >&2 echo "empty env value HAWK_GATEWAY"
fi

