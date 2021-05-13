#!/bin/sh

sh startup.sh

source jvm.sh

java ${JAVA_OPTS}  -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE}  -jar /app/jar/app.jar


