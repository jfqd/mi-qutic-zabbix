#!/bin/bash
set -o pipefail

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

if test -z "$1" ; then
  echo "You need to supply a DOMAIN to check. Quitting"
  exit 1;
fi
if test -z "$2" ; then
  echo "You need to supply a SUBDOMAIN to check. Quitting"
  exit 1;
fi
if test -z "$3" ; then
  echo "You need to supply a PORT to check. Quitting"
  exit 1;
fi

DOMAIN=$1
SUBDOMAIN=$2
PORT=$3

SHOULD=$(ldns-dane -d create ${DOMAIN} 443 2>/dev/null | awk '{ print $8 }' | tr '[:lower:]' '[:upper:]')
REAL=$(dig -4 +short TLSA _${PORT}._tcp.${SUBDOMAIN}.${DOMAIN} | awk '{ print $4$5 }' | tr '[:lower:]' '[:upper:]')

EXIT=0
if [[ $(echo ${REAL} | grep -c "${SHOULD}") > 0 ]]; then
  echo "OK"
else
  echo "${SHOULD}"
  EXIT=1
fi

exit $EXIT