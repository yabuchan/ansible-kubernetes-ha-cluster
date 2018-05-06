#!/bin/bash
# This script is for 
# 1. Setup ssh access from master to workers.
# 2. Setup ssh access from first master to the other masters (optional to be able to use scp)
# You may manually do above two tasks instead of running this script.
mkdir -p ../_ssh && ssh-keygen -t rsa -b 2048 -N "" -f ../_ssh/id_rsa # Generate ssh key

cp ../inventory/mycluster ../inventory/mycluster-init
sed -i -e 's/centos/root/g' ../inventory/mycluster-init

cd ../ && \
  ansible-playbook -i inventory/mycluster playbooks/copy-ssh-key-id.yaml --private-key=$PRIVATE_KEY && \

  # access using password is discouraged, but if you want, you can do it with:
  # ansible-playbook -i inventory/mycluster playbooks/copy-ssh-key-id.yaml --ask-pass

  # Check connectivity
  ansible -i inventory/mycluster-init -m ping all-vms
cd scripts

# remove temporal init file
rm -f ../inventory/mycluster-init