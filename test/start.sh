#!/bin/bash
cp -R /shared/$1 /opt/
pushd /opt/$1
rvm jruby do jrlint
rvm jruby do rubocop
rvm jruby do gem build $1.gemspec
pushd /opt/logstash
export GEM_HOME="$(pwd)/vendor/bundle/jruby/1.9"
export GEM_PATH=
export JRUBY_JAR="$(pwd)/vendor/jar/jruby-complete-1.7.11.jar"
java -jar "$JRUBY_JAR" -S gem install /opt/$1/$1-*.gem
#bin/plugin install --no-verify /opt/$1/$1-*.gem
#bin/plugin list
project=$(ls vendor/bundle/jruby/1.9/gems/ | grep $1 )
cp -R vendor/bundle/jruby/1.9/gems/${project}/lib/logstash/* lib/logstash/
timeout 120 bin/logstash --debug -e "input { $2 {} } output {stdout { codec => rubydebug } }"
exit 0
