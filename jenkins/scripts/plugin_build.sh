#!/bin/bash
set +x
export PATH=$PATH:/usr/local/rvm/bin/
pushd "$WORKSPACE/logstash-input-gitrepo_${BUILD_NUMBER}"
echo "====================="
echo "Building a Gem file  "
echo "====================="
rvm jruby do gem build logstash-input-gitrepo.gemspec
mv *.gem /
popd
