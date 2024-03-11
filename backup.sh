#!/bin/bash


TIMESTAMP=$(date +%Y%m%d%H%M%S)
HOSTNAME=$(hostname)
REMOTE_PATH="/mnt/pve/remote"


log() {
   echo "$(date +%Y%m%d_%H%M%S) [${HOSTNAME}] $1" >> "${REMOTE_PATH}/backup.log"
}


log "Backup starting..."

mount -a
cd /root

# NOTE: Node backup contains keys so we only do this manually.
# NODE_BACKUP_FILENAME="backup_${HOSTNAME}_${TIMESTAMP}.tar.gz"
# log "Creating NODE backup: ${NODE_BACKUP_FILENAME}..."
# mkdir -p /etc/pve/backups_from_elsewhere/root
# mkdir -p /etc/pve/backups_from_elsewhere/etc
# mkdir -p /etc/pve/backups_from_elsewhere/etc/kernel
# mkdir -p /etc/pve/backups_from_elsewhere/etc/modprobe.d
# cp /root/*.* /etc/pve/backups_from_elsewhere/root/
# cp /etc/hosts /etc/pve/backups_from_elsewhere/etc/hosts
# cp /etc/fstab /etc/pve/backups_from_elsewhere/etc/fstab
# cp /etc/kernel/cmdline /etc/pve/backups_from_elsewhere/etc/kernel/cmdline
# cp /etc/modules /etc/pve/backups_from_elsewhere/etc/modules
# cp /etc/default/grub /etc/pve/backups_from_elsewhere/etc/grub
# cp /etc/modprobe.d/iommu_unsafe_interrupts.conf /etc/pve/backups_from_elsewhere/etc/modprobe.d/iommu_unsafe_interrupts.conf
# crontab -l > /etc/pve/backups_from_elsewhere/etc/crontab.txt
# ip address > /etc/pve/backups_from_elsewhere/ip_address.txt
# tar -zcvf "${NODE_BACKUP_FILENAME}" /etc/pve/
# log "Pushing NODE backup to remote: ${NODE_BACKUP_FILENAME}"
# mv "${NODE_BACKUP_FILENAME}" "${REMOTE_PATH}/node_backups/${NODE_BACKUP_FILENAME}"
# find "${REMOTE_PATH}/node_backups/" -mindepth 1 -mtime +7 -delete

log "Pushing VM backups to remote..."
rsync -r -h --progress --ignore-existing /local-zfs/backup/ "${REMOTE_PATH}"
rsync -r -h --progress --ignore-existing /var/lib/vz/ "${REMOTE_PATH}"
log "Pushed VM backups to remote"

log "Backup completed"
