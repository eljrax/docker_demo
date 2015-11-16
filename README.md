**Note that Docker release 1.9 has support for networking drivers which you may find easier to use rather than open vSwitch as used in this playbook.**
# Docker Demo Playbook

This is a quick and dirty playbook which sets up an openvswitch mesh
network between an arbitrary number of servers.
It sets up Docker to use this network to allow cross-host
communication for containers.  
It sets up a docker-swarm cluster across the hosts, with the one having the
host-var swarm_manager running the manager container.

**Check/modify the vars at the top of playbook.yml to suit your needs.**

This is developed and tested on Ubuntu 14.04 VMs on the Rackspace cloud 
using a Cloud Network between the hosts.

A reboot after the playbook has finished running is advisable - or in some
circumstances required!

Also note that you need to do the subnetting yourself, and set the
docker_range host-var in the inventory to split up the ranges docker will
allocate to containers. See [inventory.sample](https://github.com/eljrax/docker_demo/blob/master/inventory.sample) for an example

Note: It will open up the UFW firewall entirely on the interface you specify
as 'cloud_network_iface'. This should be a private network shared between the
hosts.

Once you have run the play and rebooted the hosts, you should be able to log in to the host you
specified as swarm_manager in the inventory and see this

```
# Make sure we communicate with the swarm manager, and not local docker instance
root@el-docker-demo-1:~# source ~/swarm_manager
root@el-docker-demo-1:~# docker info
Containers: 34
Images: 14
Role: primary
Strategy: spread
Filters: affinity, health, constraint, port, dependency
Nodes: 3
 el-docker-demo-1: 10.10.10.1:2375
  └ Containers: 12
  └ Reserved CPUs: 0 / 2
  └ Reserved Memory: 0 B / 3.856 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=3.13.0-63-generic, operatingsystem=Ubuntu 14.04.3 LTS, storagedriver=aufs
 el-docker-demo-2: 10.10.10.2:2375
  └ Containers: 11
  └ Reserved CPUs: 0 / 2
  └ Reserved Memory: 0 B / 3.856 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=3.13.0-63-generic, operatingsystem=Ubuntu 14.04.3 LTS, storagedriver=aufs
 el-docker-demo-3: 10.10.10.3:2375
  └ Containers: 11
  └ Reserved CPUs: 0 / 2
  └ Reserved Memory: 0 B / 3.856 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=3.13.0-63-generic, operatingsystem=Ubuntu 14.04.3 LTS, storagedriver=aufs
CPUs: 6
Total Memory: 11.57 GiB
Name: a5bd8ccdb9d3
```

The playbook does create and start a consul server container on the
`swarm_manager` host, and writes /etc/consul.json on all the others. For the
purposes of the demo, I'm running with a single consul master. But in
production, you definitely want at least three!
Do test this, try this:

```
root@el-docker-demo-1:~# CONSUL_SERVER="$(docker inspect -f '{{.NetworkSettings.IPAddress}}' consul_server)"
root@el-docker-demo-1:~# docker run -ti --rm progrium/consul -data-dir=/consul_data -retry-join=$CONSUL_SERVER -data-dir=/tmp/consul -dc=dc1 &
...
==> Consul agent running!
         Node name: '619951e7ee9b'
        Datacenter: 'dc1'
...
    2015/09/18 16:51:06 [INFO] agent: Joining cluster...
    2015/09/18 16:51:06 [INFO] agent: (LAN) joining: [172.17.64.18]
# Then do a lookup for that node name:
root@el-docker-demo-1:~# dig +short @$CONSUL_SERVER 619951e7ee9b.node.dc1.consul
172.17.128.31
```

And to test the networking setup:
```
# Start a netcat container on host1 listening on 1234 (I just built one from
# centos:7 and called it crosstest)
root@el-docker-demo-1:~# netcat_container=$(docker -H 10.10.10.1:2375 run -d crosstest nc -l 1234)
root@el-docker-demo-1:~# docker -H 10.10.10.1:2375 inspect -f '{{.NetworkSettings.IPAddress}}' $netcat_container
172.17.64.27
# Switch to one of the other hosts
root@el-docker-demo-2:~# docker run --rm -ti crosstest /bin/sh -c 'echo test from another node | nc 172.17.64.99 1234'
# Back on host1
root@el-docker-demo-1:~# grep $netcat_container /var/log/fluentd_logs/docker.[0-9]*
/var/log/fluentd_logs/docker.20150918.b52002e5f37da2ee6.log:20150918T180446+0100
docker.4a2ac25a64dc     {"source":"stdout","log":"test from another node","container_id":"4a2ac25a64dc03b996a973228be9cb513079cb2ac8e4539b05a09ca1a310e6a8","container_name":"/elated_torvalds"}
```

And to verify the swarm working:
```
root@el-docker-demo-2:~# source ~/swarm_manager
root@el-docker-demo-2:~# for i in {1..50} ; do docker run -ti centos:7 /bin/sh -c 'echo swarm from node 2' ; done
# Switch to your ansible host
root@el-docker-demo-admin:~# ansible -oi inventory docker -m shell -a "docker ps -a --no-trunc | grep 'from node 2' | wc -l"
el-docker-demo-1.example.com | success | rc=0 | (stdout) 16
el-docker-demo-2.example.com | success | rc=0 | (stdout) 17
el-docker-demo-3.example.com | success | rc=0 | (stdout) 17 
```
