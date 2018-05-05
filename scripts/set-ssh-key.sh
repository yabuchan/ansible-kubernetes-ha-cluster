#!/bin/bash
# This script is for 
# 1. Setup ssh access from master to workers.
# 2. Setup ssh access from first master to the other masters (optional to be able to use scp)
# You may manually do above two tasks instead of running this script.
mkdir -p ../.ssh
ssh-keygen -t rsa -b 2048 -f ../.ssh/id_rsa # Generate ssh key
cd ../
cp ../.ssh/id_rsa ~/.ssh/id_rsa
cp ../.ssh/id_rsa.pub ~/.ssh/id_rsa.pub
ansible-playbook -i inventory/mycluster playbooks/copy-ssh-key-id.yaml --private-key=$PRIVATE_KEY
