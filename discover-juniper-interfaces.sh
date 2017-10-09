#!/bin/bash
# 2017 Łukasz Trąbiński <lukasz@trabinski.net>
# Discover juniper interfaces like xe, ge, ae, et and generate
# script to read data from interfaces

# configuration
device="$1"
community="$2"
# Path to get-iftraffic-juniper.sh scirpt
SCRIPT="/usr/local/sbin/get-iftraffic-juniper.sh"



TEMP="/tmp/disc.tmp"

if [ $# -lt 2  ]
  then
    echo "No arguments"
    echo "Usage $0 Device_name snmp_community"

else

rm -f $TEMP
snmpwalk -Os -c $community -v2c $device ifDescr |grep 'xe\| ae\|ge\|et' |awk '{print $4}' |awk -F "." '{print $1}' |sort |uniq >$TEMP
for a in `cat /tmp/disc.tmp`;do echo "$SCRIPT $a $device $community";done
rm -f $TEMP

fi
