#!/bin/bash
source /app/bin/jvm-options-${PERFORMANCE_LEVEL:-NORMAL}.sh
source /app/bin/jvm-options.sh

export LD_LIBRARY_PATH=/app/shared/jprofiler11.0.1/linux-x64

JAVA_OPTS="${JAVA_OPTS} -javaagent:/app/lib/jmx_prometheus_javaagent.jar=9001:/app/lib/config.yaml"

if [[ ${JPROFILER:-0} == "1" ]]; then
  JAVA_OPTS="${JAVA_OPTS} -agentpath:/app/shared/jprofiler11.0.1/linux-x64/libjprofilerti.so=port=8849,nowait"
fi

if [[ ${REMOTE_DEBUG:-0} == "1" ]]; then
  JAVA_OPTS="${JAVA_OPTS} -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005"
fi

if [[ -n "${JAVA_PROPS}" ]]; then
  JAVA_PROPS=$(echo "${JAVA_PROPS}" | tr -d '"')
  JAVA_OPTS="${JAVA_PROPS} ${JAVA_OPTS}"
fi


agentFile="/app/bin/agent.jar"
s=`curl -s -w "%{http_code}" -H "Connection: close" http://${TRAFFIC_ADDR:-hawk-traffic.hawk:8080}/file\?fileName\=hawk-agent.jar -o ${agentFile}`
if [ $s -eq "200" ];then
  if [ -s ${agentFile} ]; then
    JAVA_OPTS="${JAVA_OPTS} -javaagent:${agentFile} "
  fi
fi


echo "Java options $JAVA_OPTS"
