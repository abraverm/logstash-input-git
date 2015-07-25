#!/bin/bash
cd "$WORKSPACE/logstash-input-gitrepo_ci/docker/ELK-gitrepo"
echo "====================="
echo "Removing Environment"
echo "====================="
docker-compose stop
docker-compose rm --force
