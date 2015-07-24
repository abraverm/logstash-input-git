FROM fedora
RUN rpm --rebuilddb && \
yum install -y java-1.8.0-openjdk openssh-server openssh-client git
# configure ssh
RUN mkdir /root/.ssh
RUN chmod 700 /root/.ssh
RUN echo 'root:123456' |chpasswd
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN ssh-keygen -b 1024 -t rsa -f /etc/ssh/ssh_host_key -N ''
RUN ssh-keygen -b 1024 -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -b 1024 -t dsa -f /etc/ssh/ssh_host_dsa_key -N ''
WORKDIR /opt
EXPOSE 22
ENTRYPOINT  /usr/sbin/sshd -D
MAINTAINER Alexander Braverman "abraverm@redhat.com"
ADD authorized_keys /root/.ssh/
ADD ./sshd.pam /etc/pam.d/sshd
