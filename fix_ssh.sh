#!/bin/bash

ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R pve-1
ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R pve-7
ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R pve-8

ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R pve-1.home
ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R pve-7.home
ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R pve-8.home

ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R 192.168.0.5
ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R 192.168.0.7
ssh-keygen -f "/etc/ssh/ssh_known_hosts" -R 192.168.0.8

/usr/bin/ssh -e none -o 'HostKeyAlias=pve-1' root@192.168.0.5 /bin/true
/usr/bin/ssh -e none -o 'HostKeyAlias=pve-7' root@192.168.0.7 /bin/true
/usr/bin/ssh -e none -o 'HostKeyAlias=pve-8' root@192.168.0.8 /bin/true
/usr/bin/ssh -e none -o 'HostKeyAlias=pve-1.home' root@192.168.0.5 /bin/true
/usr/bin/ssh -e none -o 'HostKeyAlias=pve-7.home' root@192.168.0.7 /bin/true
/usr/bin/ssh -e none -o 'HostKeyAlias=pve-8.home' root@192.168.0.8 /bin/true

echo "Done!"
