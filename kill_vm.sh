#!/bin/bash

VM_ID=$1
PROCESS_ID=$(ps -ef | grep "/usr/bin/kvm -id ${VM_ID}" | grep -v grep | awk '{print $2}')
if [ -z "${PROCESS_ID}" ]
then
        PROCESS_ID=$(ps aux | grep "/usr/bin/lxc-start -F -n ${VM_ID}" | grep -v grep | awk '{print $2}')
fi
if [ -z "${PROCESS_ID}" ]
then
        echo "Could not fetch process ID!"
        exit 1
fi

echo "Killing VM_ID=${VM_ID} PROCESS_ID=${PROCESS_ID}"
kill -9 ${PROCESS_ID}
# qm stop ${VM_ID}
echo "done!"
