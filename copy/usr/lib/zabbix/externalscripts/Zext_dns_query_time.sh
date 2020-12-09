#!/bin/sh
if test -z "$1" ; then
  echo "You need to supply a DOMAIN to check. Quitting"
  exit 0;
fi
if test -z "$2" ; then
  echo "You need to supply a DNS server to check. Quitting"
  exit 0;
fi

DOMAIN=$1
DNS_SERVER=$2

MYTIME=$(dig ${DOMAIN} @${DNS_SERVER} | grep "Query time:" |awk '{print $4}' )
if [ $? -eq 0 ]; then
  echo $MYTIME
else
  echo 0
fi