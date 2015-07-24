#!/bin/bash
set +x
echo "----------------------------------------------------"
echo "Stable (1.4) Packaged (NOT source code) Logstash"
echo "----------------------------------------------------"
pushd /opt/logstash
# Installing the plugin using gem will make it download dependecies
# declared in gemspec file but it will also ignore Gemfile.
#
# specific_install - A Rubygem plugin that allows you to install an
# "edge" gem straight from its github repository, or install one
# from an arbitrary url web
export GEM_HOME="$(pwd)/vendor/bundle/jruby/1.9"
export GEM_PATH=
export JRUBY_JAR="$(pwd)/vendor/jar/jruby-complete-1.7.11.jar"
# Installing the plugin
ls -l /*.gem
java -jar "$JRUBY_JAR" -S gem install /logstash-input-gitrepo-*.gem
cp -R vendor/bundle/jruby/1.9/gems/logstash-input-gitrepo*/lib/logstash/* lib/logstash/
echo "-----------------------"
echo "Testing Plugin on 1.4.2"
echo "-----------------------"
timeout 60 bin/logstash -e 'input { gitrepo {} } output {stdout { } }' || exit 0
