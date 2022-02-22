#!/bin/bash

mount -a
rsync -r -h --progress --ignore-existing /mnt/pve/backup/ /mnt/proxmox
