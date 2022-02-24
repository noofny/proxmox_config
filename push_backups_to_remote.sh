#!/bin/bash

mount -a
rsync -r -h --progress --ignore-existing /local-zfs/backup/ /mnt/proxmox
