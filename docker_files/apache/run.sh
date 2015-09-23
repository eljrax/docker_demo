#!/usr/bin/env bash
echo "JOINING CONSUL CLUSTER AT: $JOIN_IP"
/usr/local/bin/consul agent -data-dir /consul_data -retry-join=$JOIN_IP -config-dir=/etc/consul.d -dc=dc1 &
# Quick and dirty way to log apache requests to stdout
rm /var/log/apache2/access.log
rm /var/log/apache2/error.log
ln -s /dev/stdout /var/log/apache2/access.log
ln -s /dev/stdout /var/log/apache2/error.log
/usr/sbin/apache2ctl -D FOREGROUND
