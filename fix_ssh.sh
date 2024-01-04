#!/bin/bash

ssh-keygen -f "/root/.ssh/known_hosts" -R pve-1
ssh-keygen -f "/root/.ssh/known_hosts" -R pve-2
ssh-keygen -f "/root/.ssh/known_hosts" -R pve-3
ssh-keygen -f "/root/.ssh/known_hosts" -R pve-1.home
ssh-keygen -f "/root/.ssh/known_hosts" -R pve-2.home
ssh-keygen -f "/root/.ssh/known_hosts" -R pve-3.home
ssh-keygen -f "/root/.ssh/known_hosts" -R 192.168.0.5
ssh-keygen -f "/root/.ssh/known_hosts" -R 192.168.0.6
ssh-keygen -f "/root/.ssh/known_hosts" -R 192.168.0.7
echo "Hit ENTER to continue (1/3)"
read

ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R pve-1
ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R pve-2
ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R pve-3
ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R pve-1.home
ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R pve-2.home
ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R pve-3.home
ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R 192.168.0.5
ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R 192.168.0.6
ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R 192.168.0.7
echo "Hit ENTER to continue (2/3)"
read

ssh-keygen -f "/etc/pve/priv/known_hosts" -R pve-1
ssh-keygen -f "/etc/pve/priv/known_hosts" -R pve-2
ssh-keygen -f "/etc/pve/priv/known_hosts" -R pve-3
ssh-keygen -f "/etc/pve/priv/known_hosts" -R pve-1.home
ssh-keygen -f "/etc/pve/priv/known_hosts" -R pve-2.home
ssh-keygen -f "/etc/pve/priv/known_hosts" -R pve-3.home
ssh-keygen -f "/etc/pve/priv/known_hosts" -R 192.168.0.5
ssh-keygen -f "/etc/pve/priv/known_hosts" -R 192.168.0.6
ssh-keygen -f "/etc/pve/priv/known_hosts" -R 192.168.0.7
echo "Hit ENTER to continue (3/3)"
read

/usr/bin/ssh -e none -o 'HostKeyAlias=pve-1' root@192.168.0.5 /bin/true
/usr/bin/ssh -e none -o 'HostKeyAlias=pve-2' root@192.168.0.6 /bin/true
/usr/bin/ssh -e none -o 'HostKeyAlias=pve-3' root@192.168.0.7 /bin/true
/usr/bin/ssh -e none -o 'HostKeyAlias=pve-1.home' root@192.168.0.5 /bin/true
/usr/bin/ssh -e none -o 'HostKeyAlias=pve-2.home' root@192.168.0.6 /bin/true
/usr/bin/ssh -e none -o 'HostKeyAlias=pve-3.home' root@192.168.0.7 /bin/true

echo "Done!"
