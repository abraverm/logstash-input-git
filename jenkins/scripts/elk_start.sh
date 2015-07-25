#!/bin/bash
pushd "$WORKSPACE/logstash-input-gitrepo_ci/docker/ELK-gitrepo"
echo "====================="
echo "Starting Environment"
echo "====================="
docker-compose up -d
popd
