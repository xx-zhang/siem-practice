#!/bin/bash

IFACE=eth0

say() {
    printf 'rustup: %s\n' "$1"
}

err() {
    say "$1" >&2
    exit 1
}

need_cmd() {
    if ! check_cmd "$1"; then
        err "need '$1' (command not found)"
    fi
    usage
}

check_cmd() {
    command -v "$1" > /dev/null 2>&1
}

#assert_nz() {
#    if [ -z "$1" ]; then err "assert_nz $2"; fi
#}


function usage() {
cat << EndOfHelp
    说明: $0 <func_name> <args> | tee $0.log
    20191127: inital-all by r4164
    20191129: packet it to rhl7
    suricata 启动停止日志轮转等的操作
EndOfHelp
}


curdir=$(
  cd $(dirname $0)
  pwd
)/

suri_home=${curdir}
cd ${suri_home}

function start() {
   iptables -I INPUT  -j NFQUEUE
   iptables -I OUTPUT  -j NFQUEUE
   say "start nfq."

  ./bin/suricata -c ${suri_home}etc/suricata/suricata.yaml -q 0 -D
}

function stop() {
  iptables -F
  iptables -t nat -F

  ps -ef | grep suricata | awk '{print $2}' |xargs kill -9 ;
  rm -rf ${suri_home}var/run/* ;
  say 'Stop Suricata OK'
}

function restart() {
  stop
  sleep 3
  start
}

function version() {
  ./bin/suricata -V
}

function status() {
  suri_thread_num=$(ps -ef | grep 'bin/suricata' | grep -v grep | wc -l)
  if [ $suri_thread_num -gt 0 ];then
      echo 'RUNNING; thread num is '$suri_thread_num
  else
      echo '[X]suricata is stoped'
  fi
}

function lograte() {
  if [ ! -d ${suri_home}var/log/suricata/old ]; then
      mkdir -p ${suri_home}var/log/suricata/old ;
  fi

  mv var/log/suricata/eve.json suricata-eve.json && \
     kill -HUP $(ps -ef | grep suricata | grep -v grep | grep '/bin/suricata' | awk  '{print $2}') && \
     cd ${suri_home}var/log/suricata && \
      tar czf old/eve-$(date '+%Y%m%d%H%M').tar.gz  suricata-eve.json && \
          rm -rf suricata-eve.json ;
}

function filestore_lograte(){
  # 打包 filestore
  cd ${suri_home}var/log/suricata && \
  mv filestore filestore-tmp && mkdir filestore && \
  tar czf filestore--$(date '+%Y%m%d%H%M').tar.gz filestore-tmp && \
  rm -rf filestore-tmp
}

#need_cmd

case "$1" in
"start")
  start
  ;;
"restart")
  restart
  ;;
"stop")
  stop
  ;;
"version")
  version
  ;;
"status")
  status
  ;;
"lograte")
  lograte
  ;;
*)
  echo "usage:(start|stop|restart|status|version|lograte)"
  usage
  exit
  ;;
esac


