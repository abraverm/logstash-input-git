#!/bin/bash
cd "$WORKSPACE/logstash-input-gitrepo_ci/docker/ELK"
echo "====================="
echo "     Setting DNS"
echo "====================="
lid=$(docker-compose ps -q logstash)
lip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $lid)
eid=$(docker-compose ps -q elasticsearch)
eip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $eid)
kid=$(docker-compose ps -q kibana)
kip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $kid)

echo "address=\"/logstash/${lip}\"" >> /etc/dnsmasq.d/0hosts
echo "address=\"/elasticsearch/${eip}\"" >> /etc/dnsmasq.d/0hosts
echo "address=\"/kibana/${kip}\"" >> /etc/dnsmasq.d/0hosts

cat /etc/dnsmasq.d/0hosts
dnsmasq -D
