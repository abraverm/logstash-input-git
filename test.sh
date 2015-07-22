#!/bin/bash
pushd test
./build.sh
popd
project=$(basename "$PWD")
docker run --rm -t -v $PWD:/shared/$project abraverm/project:git /opt/start.sh $project gitrepo
notify-send 'Build Finished!' 'Build execution finished' --icon=dialog-information
