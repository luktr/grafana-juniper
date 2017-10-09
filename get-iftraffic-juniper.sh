#!/bin/bash
# Traffic reader from snmp interface index for juniper devices
# 2017 Łukasz Trąbiński <lukasz@trabinski.net>
# Version 1.0


#for debug
#set -x

#configuration
# IP
influxdb_ip=127.0.0.1
# influxdb port
influxdb_port=8086
# influx database name
influxdb_db=db_name


# Do NOT MODIFY
in="$1"
IP=$2
community=$3

if [ $# -lt 3  ]
  then
    echo "No arguments"
    echo "Usage $0 Interface_name IP_Device community"

else

if=`snmpwalk -Os -c $community -v2c $IP ifDescr |grep -P  ''$in'(?=\s|$)' |awk -F "ifDescr." '{print $2}' |awk -F "=" '{print $1}'`

Output_bytes=`snmpwalk -Os -c $community -v2c $IP enterprises.2636.3.3.1.1.8.$if | awk -F ": " '{print $2}'`
Intput_bytes=`snmpwalk -Os -c $community -v2c $IP enterprises.2636.3.3.1.1.7.$if | awk -F ": " '{print $2}'`




if_in=`echo $IP\.if_in_$1,host=$IP value=$Intput_bytes`
if_out=`echo $IP\.if_out_$1,host=$IP value=$Output_bytes`

# for debug only
#echo $if_in
#echo $if_out
#


curl -i -XPOST 'http://'$influxdb_ip':'$influxdb_port'/write?db='$influxdb_db'' --data-binary "$if_in"
curl -i -XPOST 'http://'$influxdb_ip':'$influxdb_port'/write?db='$influxdb_db'' --data-binary "$if_out"


fi

