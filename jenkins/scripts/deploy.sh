#!/bin/bash
pushd "$WORKSPACE/logstash-input-gitrepo_ci/docker/ELK-deploy"

echo "========================"
echo "Removing old Deployment"
echo "========================"
docker-compose stop
docker-compose rm --force
echo "========================"
echo "Starting new Deployment"
echo "========================"
docker-compose up -d

echo "================================"
echo "Deploying the Plugin on Logstash"
echo "================================"
lid=$(docker-compose ps -q logstash)
logstash=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $lid)

sshpass -p123456 scp -o StrictHostKeyChecking=no -r "$WORKSPACE/logstash-input-gitrepo_${BUILD_NUMBER}" "root@$logstash:/"
sshpass -p123456 scp -o StrictHostKeyChecking=no logstash.conf.m4 "root@$logstash:/"
sshpass -p123456 ssh -o StrictHostKeyChecking=no "root@$logstash" /bin/bash << ENDSSH
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

sshpass -p123456 ssh -o StrictHostKeyChecking=no "root@$logstash" /bin/bash << ENDSSH
set +x
echo "-----------------"
echo "Installing Plugin"
echo "-----------------"
pushd /opt/logstash
export GEM_HOME="/opt/logstash/vendor/bundle/jruby/1.9"
export GEM_PATH=
java -jar /opt/logstash/vendor/jar/jruby-complete-1.7.11.jar -S gem install /logstash-input-gitrepo-*.gem
cp -R vendor/bundle/jruby/1.9/gems/logstash-input-gitrepo*/lib/logstash/* lib/logstash/
ENDSSH
sshpass -p123456 ssh -o StrictHostKeyChecking=no "root@$logstash" /bin/bash << ENDSSH
set +x
echo "------------------------"
echo "Creating Configurations"
echo "------------------------"
m4 -DES_HOST="$ES_HOST" -DES_PORT="$ES_PORT" -DES_USER="$ES_USER" -DES_PASSWORD="$ES_PASSWORD" -DBZ_HOST="$BZ_HOST" -DBZ_PRODUCT="$BZ_PRODUCT" /logstash.conf.m4 > /logstash.conf
echo "-----------------"
echo "Starting Logstash"
echo "-----------------"

nohup /opt/logstash/bin/logstash -f /logstash.conf -l /logstash.log < /dev/null > /std.out 2> /std.err &
ENDSSH
echo "==================="
echo "Finished Deployment"
echo "==================="
popd
