#!/bin/bash


# TODO: migrate all this to ansible
#       ...or at least...
# TODO: make this script idempotent!


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


# scripts
echo ""
echo "Pulling scripts..."
cd /root
wget https://raw.githubusercontent.com/noofny/proxmox_config/master/fix_ssh.sh
chmod +x ./fix_ssh.sh
wget https://raw.githubusercontent.com/noofny/proxmox_config/master/kill_vm.sh
chmod +x ./kill_vm.sh
wget https://raw.githubusercontent.com/noofny/proxmox_config/master/backup.sh
chmod +x ./backup.sh


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


# zfs
echo ""
echo "Copying ZFS config..."
echo "(see https://pve.proxmox.com/wiki/ZFS:_Tips_and_Tricks)"
wget https://raw.githubusercontent.com/noofny/proxmox_config/master/zfs.conf
cp zfs.conf /etc/modprobe.d/zfs.conf


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


# cockpit
apt update && apt install cockpit -y
sed -i 's/^root/# root/g' /etc/cockpit/disallowed-users
# NOTE: fix for networking...https://cockpit-project.org/faq#error-message-about-being-offline
wget https://raw.githubusercontent.com/noofny/proxmox_config/master/10-globally-managed-devices.conf
cp 10-globally-managed-devices.conf /etc/NetworkManager/conf.d/10-globally-managed-devices.conf
nmcli con add type dummy con-name fake ifname fake0 ip4 1.2.3.4/24 gw4 1.2.3.1
# plugin - identities
curl -LO https://github.com/45Drives/cockpit-identities/releases/download/v0.1.12/cockpit-identities_0.1.12-1focal_all.deb
apt install ./cockpit-identities_0.1.12-1focal_all.deb -y
# plugin - filesharing
curl -LO https://github.com/45Drives/cockpit-file-sharing/releases/download/v3.2.9/cockpit-file-sharing_3.2.9-2focal_all.deb
apt install ./cockpit-file-sharing_3.2.9-2focal_all.deb -y
# plugin - navigator
wget -qO - https://repo.45drives.com/key/gpg.asc | gpg --dearmor -o /usr/share/keyrings/45drives-archive-keyring.gpg
curl -sSL https://repo.45drives.com/lists/45drives.sources -o /etc/apt/sources.list.d/45drives.sources
apt update && apt install cockpit-navigator -y



# reboot
reboot now


echo ""
echo "Setup complete - you can access the console at https://$(hostname -I):8006/"
echo "Configure : script complete!"
