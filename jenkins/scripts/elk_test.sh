#!/bin/bash
set +x
echo "====================="
echo "Testing on Logstash"
echo "====================="
sshpass -p123456 scp -o StrictHostKeyChecking=no -r "$WORKSPACE/logstash-input-gitrepo_${BUILD_NUMBER}" root@logstash:/
sshpass -p123456 ssh -o StrictHostKeyChecking=no root@logstash /bin/bash << ENDSSH
export JAVACMD="/bin/java"
export PATH=$PATH:/usr/local/rvm/bin/
set +x
echo "-------------------"
echo "Building Plugin Gem"
echo "-------------------"
pushd /logstash-input-gitrepo*
rvm jruby do gem build logstash-input-gitrepo.gemspec
mv *.gem /
popd
ENDSSH

sshpass -p123456 ssh -o StrictHostKeyChecking=no root@logstash /bin/bash << ENDSSH
set +x
echo "----------------------------------"
echo "Installing Plugin and running test"
echo "----------------------------------"
pushd /opt/logstash
export GEM_HOME="/opt/logstash/vendor/bundle/jruby/1.9"
export GEM_PATH=
java -jar /opt/logstash/vendor/jar/jruby-complete-1.7.11.jar -S gem install /logstash-input-gitrepo-*.gem
cp -R vendor/bundle/jruby/1.9/gems/logstash-input-gitrepo*/lib/logstash/* lib/logstash/

timeout 120 bin/logstash -e 'input { gitrepo {} } output { elasticsearch { host => elasticsearch } stdout {codec => rubydebug} }' || exit 0
ENDSSH

echo "------------------------------------------"
echo "Quering Elasticsearch for the test results"
echo "------------------------------------------"
curl 'http://elasticsearch:9200/_search?pretty'
