#!/bin/sh

#INFO: ejecutar una sola instancia de un script, ej. desde cron
DIR=`pwd`
KEY=$DIR/'executeProc'

pidfile=$KEY.pid
if [ -f "$pidfile" ] ; then
	PID=`cat $pidfile`
	echo "$PID"
	if kill -0 "$PID" 2>/dev/null; then
    echo "$KEY sigue ejecutandose PID=$PID"
    exit 1
	fi
fi  
echo $$ > $pidfile
java -jar executeProcedure.jar
