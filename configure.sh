#!/bin/bash


# TODO: make this script idempotent!
# TODO: migrate all this to ansible


echo "Configure : begin"


# timezone
echo "Setting timezone..."
timedatectl set-timezone Australia/Sydney


# bash profile
echo "Configuring bash profile..."
echo "alias ls='ls -lha'" >> ~/.bashrc
source ~/.bashrc


# community distros
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
echo "Patching..."
apt update && apt dist-upgrade -y


# packages
# TODO: include other packages like htop / net-tools
echo "Installing packages..."
apt update && apt install -y \
    curl \
    wget \
    ethtool \
    htop \
    xsensors


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


# dark theme
echo "Installing dark UI theme..."
bash <(curl -s https://raw.githubusercontent.com/Weilbyte/PVEDiscordDark/master/PVEDiscordDark.sh ) install


# scripts
echo "Creating scripts..."
SCRIPT_FILENAME='/root/kill_vm.sh'
cat << EOF > ${SCRIPT_FILENAME}
#!/bin/bash
VM_ID=$1
PROCESS_ID=$(ps -ef | grep "/usr/bin/kvm -id ${VM_ID}" | awk '{print $2}')
echo "Killing VM_ID=${VM_ID} PROCESS_ID=${PROCESS_ID}"
kill -9 ${PROCESS_ID}
qm stop ${VM_ID}
echo "done!"
EOM
chmod +x ${SCRIPT_FILENAME}



echo "Setup complete - you can access the console at https://$(hostname -I):8006/"
echo "Configure : script complete!"
