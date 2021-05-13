#!/bin/sh


sh /app/bin/startup.sh

source /app/bin/jvm.sh

sh $CATALINA_HOME/bin/catalina.sh run
