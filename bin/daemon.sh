#!/bin/bash
source  /etc/profile.d/visualis.sh &> /dev/null
export service_name="visualis-server"
export DWS_ENGINE_DEBUG="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=51206"
export DWS_ENGINE_ANAGER_HEAP_SIZE="4G"
export DWS_ENGINE_ANAGER_JAVA_OPTS="-Xms$DWS_ENGINE_ANAGER_HEAP_SIZE -Xmx$DWS_ENGINE_ANAGER_HEAP_SIZE -XX:+UseG1GC -XX:MaxPermSize=500m $DWS_ENGINE_DEBUG"

cd $(dirname $0)/..

if [ ! -d $VISUALIS_HOME ];then
    echo "Error:\$VISUALIS_HOME isn't exist"
    exit 1
fi

start() {
    # pid=$(cat ${VISUALIS_PID_PATH})
#    pid=$(ps -ef|grep $service_name |grep -v grep| awk '{print $2}')

    if [ -n "$pid" ];then
        echo $pid | tee $VISUALIS_PID_PATH &> /dev/null
        echo -e "${service_name}(`echo ${pid}`) [\033[32m started \033[0m]"
        exit 1;
    else
        echo "starting ${service_name}......"
        nohup java $DWS_ENGINE_ANAGER_JAVA_OPTS -cp $VISUALIS_HOME/conf:$VISUALIS_HOME/lib/*:$JAVA_HOME/lib/* org.apache.linkis.DataWorkCloudApplication 2>&1 > $VISUALIS_LOG_PATH/visualis.out &
        pid=$!
        echo $pid | tee $VISUALIS_PID_PATH &> /dev/null
    fi

    sleep 2
    pid=$(cat ${VISUALIS_PID_PATH})
    if [ -n "$pid" ];then
        echo $pid | tee $VISUALIS_PID_PATH &> /dev/null
        echo -e "start ${service_name}(`echo ${pid}`) [\033[32m OK \033[0m]"
    else
        echo -e "start ${service_name}(`echo ${pid}`) [\033[31m Failed \033[0m]"
    fi
}

stop() {
    if [[ ! -f "${VISUALIS_PID_PATH}" ]]; then
        echo "visualis-server is not running"
    else
        pid=$(cat ${VISUALIS_PID_PATH})
        if [[ -z "${pid}" ]]; then
        echo "visualis-server is not running"
        else
        wait_for_VISUALIS_to_die $pid 40
        # $(rm -f ${VISUALIS_PID_PATH})
        echo "visualis-server is stopped."
        fi
    fi
}

status() {

    pid=$(cat ${VISUALIS_PID_PATH})
        if [ -z "$pid" ];then
            echo -e "The ${service_name} is [\033[32m stopped \033[0m]"
        else
            echo -e "The ${service_name}(`echo ${pid}`) is [\033[32m running \033[0m]"
        fi
}

function wait_for_VISUALIS_to_die() {
  local pid
  local count
  pid=$1
  timeout=$2
  count=0
  timeoutTime=$(date "+%s")
  let "timeoutTime+=$timeout"
  currentTime=$(date "+%s")
  forceKill=1

  while [[ $currentTime -lt $timeoutTime ]]; do
    $(kill ${pid} > /dev/null 2> /dev/null)
    if kill -0 ${pid} > /dev/null 2>&1; then
      sleep 3
    else
      forceKill=0
      break
    fi
    currentTime=$(date "+%s")
  done

  if [[ forceKill -ne 0 ]]; then
    $(kill -9 ${pid} > /dev/null 2> /dev/null)
  fi
}

case $1 in
start)
    start
    ;;
stop)
    stop
    ;;
restart)
    stop
    sleep 5
    start
    ;;
status)
    status
    ;;
*)
    echo -e "\033[31mError:usage like this: \033[0m\n\033[32mservice $(basename $0) start|stop|restart|status\033[0m or \033[32m$0 start|stop|restart|status\033[0m"
    ;;
esac
