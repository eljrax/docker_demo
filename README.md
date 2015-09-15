# Docker Demo

This is a quick and dirty playbook which sets up an openvswitch mesh
network between an arbitrary number of servers.
It sets up Docker to use this network to allow cross-host
communication for containers.  
It sets up a docker-swarm cluster across the hosts, with the one having the
host-var swarm_manager running the manager container.

**Check/modify the vars at the top of playbook.yml to suit your needs.
Also note that you will need to edit [templates/network_interfaces.j2](https://github.com/eljrax/docker_demo/blob/master/templates/network_interfaces.j2)
if the interface for your private network is not eth2 as it's currently hard-coded.**
This will be addressed in a future update.

This is developed and tested on Ubuntu 14.04 VMs on the Rackspace cloud 
using a Cloud Network between the hosts.

Also note that you need to do the subnetting yourself, and set the
docker_range host-var in the inventory to split up the ranges docker will
allocate to containers. See [inventory.sample](https://github.com/eljrax/docker_demo/blob/master/inventory.sample) for an example

Note: It will open up the UFW firewall entirely on the interface you specify
as 'cloud_network_iface'. This should be a private network shared between the
hosts.
