#!/bin/bash
set +x
pushd "$WORKSPACE/logstash-input-gitrepo_${BUILD_NUMBER}"
if [ $(git diff --stat "HEAD^" -- . | wc -l) -gt 0 ] ||
   [ $(git diff --stat "HEAD^" -- docker/node/ | wc -l) -gt 0 ] ||
   [ $(git diff --stat "HEAD^" -- docker/logstash/ | wc -l) -gt 0 ]
then
  pushd "$WORKSPACE/logstash-input-gitrepo_${BUILD_NUMBER}/docker/ELK-gitrepo"
  # Step 1: Testing the environment
  {
    echo "====================="
    echo "Starting Environment"
    echo "====================="
    docker-compose up -d
    docker ps -a
    docker images
    pushd "$WORKSPACE/logstash-input-gitrepo_${BUILD_NUMBER}/docker/ELK-gitrepo"
  } && {
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
  } && {
    echo "====================="
    echo "Testing on Logstash"
    echo "====================="
    sshpass -p123456 ssh -o StrictHostKeyChecking=no root@logstash /bin/bash << ENDSSH
export JAVACMD="/bin/java"
export PATH=$PATH:/usr/local/rvm/bin/
set -x
timeout 120 /opt/logstash/bin/logstash -e 'input { generator { count => 1} } output { elasticsearch { host => elasticsearch } stdout {codec => rubydebug} }'
ENDSSH
    set +x
  }
  # Step 2: Removin the environment
  echo "====================="
  echo "Removing Environment"
  echo "====================="
  pushd "$WORKSPACE/logstash-input-gitrepo_${BUILD_NUMBER}/docker/ELK-gitrepo"
  docker-compose stop

  docker-compose rm --force

  docker rmi "logstashinputgitrepo${BUILD_NUMBER}_logstash" || echo "No docker-compose image found to remove"
fi
exit 0
