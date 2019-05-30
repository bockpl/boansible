FROM centos:7
MAINTAINER Przemyslaw Trzeciak

# Klient MFS
RUN curl "http://ppa.moosefs.com/RPM-GPG-KEY-MooseFS" > /etc/pki/rpm-gpg/RPM-GPG-KEY-MooseFS && \
curl "http://ppa.moosefs.com/MooseFS-3-el7.repo" > /etc/yum.repos.d/MooseFS.repo && \
sed -i -- 's/moosefs-3/3.0.100/g' /etc/yum.repos.d/MooseFS.repo && \
yum -y install moosefs-pro-client && \
yum clean all

# Instalacja i konfiguracja serwera ssh:
RUN (yum -y install openssh-server.x86_64) && \
(/usr/bin/ssh-keygen -A) && \
(mkdir -p /root/.ssh) && \
(yum -y install openssh-clients.x86_64) && \
(echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config) && \
(ln -s /usr/bin/ssh /usr/bin/rsh) && \
(yum clean all)

# Instalacja Ansible:
RUN (yum -y install epel-release) && \
(yum -y install ansible) && \
(yum clean all)

ADD start.sh /start.sh

CMD ["/bin/bash","-c","/start.sh"]
