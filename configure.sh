#!/bin/bash


# TODO: make this script idempotent!
# TODO: migrate all this to ansible


echo ""
echo "Configure : begin"


# timezone
echo ""
echo "Setting timezone..."
timedatectl set-timezone Australia/Sydney


# bash profile
echo ""
echo "Configuring bash profile..."
echo "alias ls='ls -lha'" >> ~/.bashrc
source ~/.bashrc


# community distros
echo ""
echo "Adding community distos..."
cat <<EOF > /etc/apt/sources.list
# Not for production use
deb http://download.proxmox.com/debian buster pve-no-subscription
EOF
cd /etc/apt/sources.list.d
cp pve-enterprise.list pve-enterprise.list.bak
# TODO - use sed for this
#        For now - manually coment out any entries in this referencing "enterprise"
#
#        it may end up looking something like this...
#
#  #-----------------------------------------------------------------
#  # Proxmox VE No-Subscription Repository
#  # This is the recommended repository for testing and non-production use.
#  # Its packages are not as heavily tested and validated.
#  # You don’t need a subscription key to access the pve-no-subscription repository.
#  
#  deb http://ftp.debian.org/debian bullseye main contrib
#  deb http://ftp.debian.org/debian bullseye-updates main contrib
#  
#  # PVE pve-no-subscription repository provided by proxmox.com,
#  # NOT recommended for production use
#  deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription
#  
#  # security updates
#  deb http://security.debian.org/debian-security bullseye-security main contrib
#
nano pve-enterprise.list


# patch
echo ""
echo "Patching..."
apt update && apt dist-upgrade -y


# packages
# TODO: include other packages like htop / net-tools
echo ""
echo "Installing packages..."
apt update && apt install -y \
    curl \
    wget \
    ethtool \
    htop \
    xsensors


# ssh/user
echo ""
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


# dark theme
echo ""
echo "Installing dark UI theme..."
bash <(curl -s https://raw.githubusercontent.com/Weilbyte/PVEDiscordDark/master/PVEDiscordDark.sh ) install


# scripts
echo ""
echo "Pulling scripts..."
cd /root
wget https://raw.githubusercontent.com/noofny/proxmox_config/master/fix_ssh.sh
chmod +x ./fix_ssh.sh
wget https://raw.githubusercontent.com/noofny/proxmox_config/master/kill_vm.sh
chmod +x ./kill_vm.sh
wget https://raw.githubusercontent.com/noofny/proxmox_config/master/push_backups_to_remote.sh
chmod +x ./push_backups_to_remote.sh


# pci-passthrough
echo ""
echo "For PCIe Passthrough (https://pve.proxmox.com/wiki/Pci_passthrough)..."
echo ""
echo "nano /etc/default/grub"
echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"'
echo 'update-grub'
echo ""
echo "nano /etc/modules"
echo "vfio"
echo "vfio_iommu_type1"
echo "vfio_pci"
echo "vfio_virqfd"
echo ""
echo 'echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf'


# misc
echo ""
echo "You may want the following to assist with SMB..."
echo ""
echo "nano ~/.smbcreds"
echo "username=YOUR_USER"
echo "password=YOUR_PASS"
echo ""
echo "chmod 600 ~/.smbcreds"
echo ""
echo "nano /etc/hosts"
echo "192.168.0.12 backup-1.local backup-1.home backup-1"
echo ""
echo "nano /etc/fstab"
echo "//backup-1/some_share /mnt/some_share   cifs    ip=192.168.0.12,uid=0,credentials=/root/.smbcreds,iocharset=utf8,vers=3.0,noperm 0 0"
echo ""


echo ""
echo "Setup complete - you can access the console at https://$(hostname -I):8006/"
echo "Configure : script complete!"
