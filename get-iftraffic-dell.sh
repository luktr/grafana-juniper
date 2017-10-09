#!/bin/bash
# Traffic reader from snmp interface index for Dell devices
# 2017 Łukasz Trąbiński <lukasz@trabinski.net>
# Version 1.0


#for debug

#set -x

#configuration
# Influxdb ip
influxdb_ip=127.0.0.1
# influxdb port
influxdb_port=8086
# Database name
influxdb_db=db_name


# Do NOT MODIFY
in="$1"
IP="$2"
community=$3

if [ $# -lt 3  ]
  then
    echo "No arguments"
    echo "Usage $0 Interface_name IP_Device community"

else


if=`snmpwalk -Os -c $community -v2c $IP ifDescr |grep "$1" |awk -F "." '{print $2}' |awk '{print $1}'`

#ifHCInOctets
Output_bytes=`snmpwalk -Os -c $community -v2c $IP ifHCOutOctets.$if | awk '{print $4}'`
Intput_bytes=`snmpwalk -Os -c $community -v2c $IP ifHCInOctets.$if | awk '{print $4}'`

int=`echo $in |sed s/" "/""/`
if_in=`echo "$IP.if_in_$int,host=$IP" value=$Intput_bytes`
if_out=`echo "$IP.if_out_$int,host=$IP" value=$Output_bytes`

# for debug only
#echo $in
#echo $if_in
#echo $if_out
#


curl -i -XPOST 'http://'$influxdb_ip':'$influxdb_port'/write?db='$influxdb_db'' --data-binary "$if_in"
curl -i -XPOST 'http://'$influxdb_ip':'$influxdb_port'/write?db='$influxdb_db'' --data-binary "$if_out"


fi

