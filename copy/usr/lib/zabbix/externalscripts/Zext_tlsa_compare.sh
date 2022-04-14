#!/bin/sh

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

SHOULD=$(ldns-dane -d create qutic.com 443 | awk '{ print $8 }' | tr '[:lower:]' '[:upper:]')
REAL=$(dig +short TLSA _25._tcp.mx1.qutic.com | awk '{ print $4$5 }' | tr '[:lower:]' '[:upper:]')

EXIT=0
if [ "${SHOULD}" = "${REAL}" ]; then
  echo "OK"
else
  echo "${SHOULD}"
  EXIT=1
fi

exit $EXIT