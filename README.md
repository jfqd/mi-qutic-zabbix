# mi-qutic-zabbix

This repository is based on [Joyent mibe](https://github.com/jfqd/mibe).

## description

kivi lx-brand image, with zabbix version 4.0.x

## Build Image

```
cd /opt/mibe/repos
/opt/tools/bin/git clone https://github.com/jfqd/mi-qutic-zabbix.git
LXBASE_IMAGE_UUID=$(imgadm list | grep qutic-lx-base | tail -1 | awk '{ print $1 }')
TEMPLATE_ZONE_UUID=$(vmadm lookup alias='qutic-lx-template-zone')
../bin/build_lx $LXBASE_IMAGE_UUID $TEMPLATE_ZONE_UUID mi-qutic-zabbix
```