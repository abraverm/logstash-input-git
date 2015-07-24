#!/bin/bash
cd "$WORKSPACE/logstash-input-gitrepo_ci/docker/ELK"
echo "====================="
echo "Removing Environment"
echo "====================="
docker-compose stop
docker-compose rm --force
docker rmi lip_gitrepo/logstash
