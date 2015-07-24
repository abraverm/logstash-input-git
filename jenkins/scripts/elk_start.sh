#!/bin/bash
pushd "$WORKSPACE/logstash-input-gitrepo_ci/docker/ELK"
echo "====================="
echo "Starting Environment"
echo "====================="
docker-compose up -d
popd
