FROM lip_gitrepo/node_test
MAINTAINER Alexander Braverman Masis <alexbmasis@gmail.com>
ENV DEV_LOG 1.5
ENV JRUBY 1.7.17
ENV STABLE_LOG 1.4.2

# Prepare jruby
RUN rpm --rebuilddb && yum install -y gcc gnupg which tar make patch m4
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby=$JRUBY
ENV PATH $PATH:/usr/local/rvm/bin/
RUN rvm alias create jruby $JRUBY
RUN rvm jruby do gem install rubocop jruby-lint bundler

# Install common gems for plugin development
WORKDIR /opt
RUN git clone -b $DEV_LOG --depth 1 https://github.com/elastic/logstash.git
RUN cd logstash && rvm jruby do bundle install
RUN rm -rf /opt/logstash

# Install stable Logstash
RUN curl -O https://download.elasticsearch.org/logstash/logstash/logstash-$STABLE_LOG.tar.gz
RUN tar zxvf logstash-$STABLE_LOG.tar.gz && mv logstash-$STABLE_LOG logstash
