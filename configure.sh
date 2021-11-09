#!/bin/bash


echo "Configure : begin"


# patch
echo "Patching..."
apt update && apt upgrade -y


# packages
echo "Installing packages..."
apt update && apt install -y \
    curl \
    wget \
    htop \
    net-tools \


# ssh/user
echo "Configuring SSH and user access..."
SSH_USER=admin
adduser --gecos "" ${SSH_USER}
usermod -aG sudo ${SSH_USER}
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa_proxmox_ssh -q -N ""
cat ~/.ssh/id_rsa_proxmox_ssh
mkdir /home/${SSH_USER}/.ssh
mv ~/.ssh/id_rsa_proxmox_ssh /home/${SSH_USER}/.ssh/id_rsa_proxmox_ssh
mv ~/.ssh/id_rsa_proxmox_ssh.pub /home/${SSH_USER}/.ssh/id_rsa_proxmox_ssh.pub
cat /home/${SSH_USER}/.ssh/id_rsa_proxmox_ssh.pub >> /home/${SSH_USER}/.ssh/authorized_keys
chown -R ${SSH_USER}:${SSH_USER} /home/${SSH_USER}
chmod 600 /home/${SSH_USER}/.ssh/id_rsa*
chmod 600 /home/${SSH_USER}/.ssh/authorized_keys
sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh


echo "Configure : script complete!"
