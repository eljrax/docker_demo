#!/usr/bin/env bash

function leave(){
    /usr/local/bin/consul leave
    sleep 2
    exit 0
}

trap leave SIGTERM

echo "JOINING CONSUL CLUSTER AT: $JOIN_IP"
/usr/local/bin/consul agent -data-dir /consul_data -retry-join=$JOIN_IP -config-dir=/etc/consul.d -dc=dc1 &
# Quick and dirty way to log php-fpm to stdout for fluentd collection
rm -f /var/log/php-fpm.log
ln -s /dev/stdout /var/log/php-fpm.log
/usr/sbin/php5-fpm -F &
wait $!
