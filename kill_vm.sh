#!/bin/bash

VM_ID=$1
PROCESS_ID=$(ps -ef | grep "/usr/bin/kvm -id ${VM_ID}" | awk '{print $2}')
echo "Killing VM_ID=${VM_ID} PROCESS_ID=${PROCESS_ID}"
kill -9 ${PROCESS_ID}
qm stop ${VM_ID}
echo "done!"
