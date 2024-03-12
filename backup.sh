#!/bin/bash


TIMESTAMP=$(date +%Y%m%d%H%M%S)
HOSTNAME=$(hostname)
LOCAL_PATH="/mnt/pve/ceph-fs-1"
REMOTE_PATH="/mnt/pve/remote"


log() {
   echo "$(date +%Y%m%d_%H%M%S) [${HOSTNAME}] $1" >> "${REMOTE_PATH}/backup.log"
}


log "Backup starting..."
mount -a
NODE_BACKUP_BASE_FOLDER="${LOCAL_PATH}/node_backup"
NODE_BACKUP_FOLDER="${NODE_BACKUP_BASE_FOLDER}/${HOSTNAME}_${TIMESTAMP}"
log "Creating NODE backup: ${NODE_BACKUP_FOLDER}..."
rm -rf "${NODE_BACKUP_BASE_FOLDER}" > /dev/null
mkdir -p "${NODE_BACKUP_FOLDER}/etc"
mkdir -p "${NODE_BACKUP_FOLDER}/etc/kernel"
mkdir -p "${NODE_BACKUP_FOLDER}/etc/modprobe.d"
cp /etc/hosts "${NODE_BACKUP_FOLDER}/etc/hosts"
cp /etc/fstab "${NODE_BACKUP_FOLDER}/etc/fstab"
cp /etc/kernel/cmdline "${NODE_BACKUP_FOLDER}/etc/kernel/cmdline"
cp /etc/modules "${NODE_BACKUP_FOLDER}/etc/modules"
cp /etc/default/grub "${NODE_BACKUP_FOLDER}/etc/grub"
cp /etc/modprobe.d/*.* "${NODE_BACKUP_FOLDER}/etc/modprobe.d/"
crontab -l > "${NODE_BACKUP_FOLDER}/etc/crontab.txt"
ip address > "${NODE_BACKUP_FOLDER}/ip_address.txt"
log "Pushing to remote..."
rsync -r -h --progress --ignore-existing "${LOCAL_PATH}/" "${REMOTE_PATH}"
find "${REMOTE_PATH}/node_backup/" -mindepth 1 -mtime +7 -delete
log "Backup completed"
