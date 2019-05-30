#!/bin/bash

# Usuniecie domyslnej konfiguracji Ansible:
mv /etc/ansible/* /tmp/ 

# Zastapienie domyslnej konfiguracji ansible:
mfsmount -H mfsmaster.dev.p.lodz.pl -S /blueocean/opt/software/Blueocean/Configs/ansible /etc/ansible && \
mfsmount -H mfsmaster.dev.p.lodz.pl -S /blueocean/opt /opt
status=$?
if [ $status -ne 0 ]; then
  echo "Faile in mount sequence: $status"
  exit $status
fi

# Start SSH process:
cp /opt/software/Blueocean/Configs/ssh/id_rsa /root/.ssh/
cp /opt/software/Blueocean/Configs/ssh/authorized_keys /root/.ssh/
chmod 700 /root/.ssh
chmod 600 /root/.ssh/id_rsa
chmod 600 /root/.ssh/authorized_keys
/usr/sbin/sshd -D &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start PBIS lwsmd process: $status"
  exit $status
fi

while sleep 60; do
ls -la /etc/ansible/check_file
status=$?
if [ $status -ne 0 ]; then
  echo "Faile in mount sequence: $status"
  exit $status
fi

LOCAL_HOSTS_PATH="/etc/hosts"
MFS_HOSTS_PATH="/opt/software/Blueocean/Configs/docker_hosts/hosts"
LOCAL_HOSTS_MD5=$(md5sum $LOCAL_HOSTS_PATH|awk '{print $1}')
MFS_HOSTS_MD5=$(md5sum $MFS_HOSTS_PATH |awk '{print $1}')

if [ $LOCAL_HOSTS_MD5 == $MFS_HOSTS_MD5 ] 
	then
		echo "Plik hosts z centralnego repozytorium jest spojny z plikiem lokalnym"
	else
		echo "Plik hosts sa rozne, konieczna aktualizacja na lokalnym hoscie"
		cp -a $MFS_HOSTS_PATH $LOCAL_HOSTS_PATH
fi

done
