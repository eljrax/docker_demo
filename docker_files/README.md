These are just quick Dockerfiles to build a simple LAMP stack, behind an nginx
load balancer, with Consul acting as the spider in the web. 

These are written for a demo, to show how this would work as **simply** and clearly as possible, and 
**should not be used in production.**

These containers all attempt to join a consul cluster, and need a seed address.
The playbook in ../ will create `/usr/local/bin/start_consul_container.sh` on
all hosts. Simply run this script on all your hosts, and then you can grab the IP of
any one of those containers.
The name of the consul container will be consul_server_N where N is the last
octet on the interface you specified as your cloud network in the playbook.

All containers should be started with --dns=ip.of.consul.server and -e JOIN_IP=ip.of.consul.server
For example:

```
$ export INVENTORY_HOST=10.10.10.1
$ cd docker_files
$ docker build -t $INVENTORY_HOST/apache .
$ docker push $INVENTORY_HOST/apache
$ start_consul_container.sh &
$ docker inspect -f '{{.NetworkSettings.IPAddress}}' consul_server_1
172.17.64.198
$ export JOIN_IP=172.17.64.198
$ docker run -ti -v /var/www/html:/var/www/html -e JOIN_IP=$JOIN_IP --dns=$JOIN_IP $INVENTORY_HOST/apache
```

The apache container will start, and register itself with the consul cluster.
The lb container runs nginx, which using LUA scripting load balances between
all containers that has registered as the 'web' service. 

See
[docker-compose.yml](https://github.com/eljrax/docker_demo/blob/master/docker_files/docker-compose.yml) for an example of how these containers work together.
