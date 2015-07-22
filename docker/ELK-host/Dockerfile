FROM lip_gitrepo/node_test
MAINTAINER Alexander Braverman Masis <abraverm@redhat.com>
RUN rpm --rebuilddb && \
yum install -y docker-io libcgroup python-pip dnsmasq sshpass PyYAML python-six unzip wget
RUN pip install -U docker-compose
RUN echo "user=root" >> /etc/dnsmasq.conf

# PhantomJS
RUN wget https://github.com/bprodoehl/phantomjs/releases/download/2.0.0-20141016/phantomjs-2.0.0-20141016-fedora20-x86_64.zip
RUN unzip *.zip
RUN rm -rf *.zip
RUN mv phantomjs*/bin/phantomjs /usr/bin/
RUN rm -rf phantomjs*

# Selelnium
RUN pip install selenium
RUN wget ftp://195.220.108.108/linux/fedora/linux/updates/20/x86_64/libicu-50.1.2-11.fc20.x86_64.rpm
RUN rpm --rebuilddb && rpm -ivh --force libicu-50.1.2-11.fc20.x86_64.rpm
RUN rm -rf *.rpm
