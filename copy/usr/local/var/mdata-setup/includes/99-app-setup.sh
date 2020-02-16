#!/bin/bash

if /native/usr/sbin/mdata-get zabbix_mysql_pwd 1>/dev/null 2>&1; then
  MYSQL_PWD=$(/native/usr/sbin/mdata-get zabbix_mysql_pwd)
  sed -i "s/# DBPassword=password/DBPassword=${MYSQL_PWD}" /etc/zabbix/zabbix_server.conf
  sed -i "s/# DBHost=127.0.0.1/DBHost=127.0.0.1" /etc/zabbix/zabbix_server.conf
fi

if mdata-get proxysql_monitor_pwd 1>/dev/null 2>&1; then
  MONITOR_PWD=`mdata-get proxysql_monitor_pwd`
  sed -i "s#monitor_password=\"monitor\"#monitor_password=\"${MONITOR_PWD}\"#" /etc/proxysql.cnf
fi

if mdata-get proxysql_admin_pwd 1>/dev/null 2>&1; then
  PROXY_ADMIN_PWD=`mdata-get proxysql_admin_pwd`
  sed -i "s#admin_credentials=\"admin:admin\"#admin_credentials=\"admin:${PROXY_ADMIN_PWD}\"#" /etc/proxysql.cnf
  cat >> /root/.my.cnf << EOF
[client]
host = 127.0.0.1
port = 3307
user = admin
password = ${PROXY_ADMIN_PWD}
prompt = 'Admin> '
EOF
chmod 0400 /root/.my.cnf
fi

if mdata-get zabbix_mysql_host 1>/dev/null 2>&1; then
  PERCONA_HOST=`mdata-get zabbix_mysql_host`
  sed -i "s/main.example.com/${PERCONA_HOST}/g" /etc/proxysql.cnf
fi

if mdata-get zabbix_mysql_fallback 1>/dev/null 2>&1; then
  PERCONA_FALLBACK=`mdata-get zabbix_mysql_fallback`
  sed -i "s/backup.example.com/${PERCONA_FALLBACK}/g" /etc/proxysql.cnf
fi

PERCONA_DB_USER=zabbix
sed -i "s#db-username#${PERCONA_DB_USER}#" /etc/proxysql.cnf

if mdata-get zabbix_mysql_pwd 1>/dev/null 2>&1; then
  PERCONA_DB_PWD=`mdata-get zabbix_mysql_pwd`
  sed -i "s#db-password#${PERCONA_DB_PWD}#g" /etc/proxysql.cnf
fi

rm /var/lib/proxysql/proxysql.db || true
mkdir -p /var/run/proxysql || true
chown -R proxysql: /var/run/proxysql  || true
service proxysql start

cat >> /root/.mysql_history << EOF
UPDATE mysql_servers SET status='OFFLINE_HARD' WHERE weight='100000';
UPDATE mysql_servers SET status='ONLINE' WHERE weight='100000';
LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;
SELECT * FROM mysql_servers;
SELECT * FROM stats.stats_mysql_connection_pool;
EOF
chmod 0600 /root/.mysql_history

/usr/local/bin/ssl-selfsigned.sh -d /etc/apache2/ssl -f zabbix

systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2
