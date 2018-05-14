#!/bin/bash
# This script is for 
# 1. Setup ssh access from master to workers.
# 2. Setup ssh access from first master to the other masters (optional to be able to use scp)
# You may manually do above two tasks instead of running this script.

while getopts "k:h" arg; do
  case $arg in
    h | --help)
      echo -e "Style:";
      echo -e "  setup-myCluster.sh -k PATH_TO_PEM\n"; 
      echo -e "Example:";
      echo -e "  setup-myCluster.sh -k  ~/.ssh/myPrivateCert.pem \n"; 
      echo -e "Required Params:";
      echo -e "    -k      Path to ssh private key from this machine to machines. e.g. ~/.ssh/xxx.pem";
      echo -e "Options:";
      echo -e "    -h      help"; 
      exit 0 
      ;;
    k)
      PRIVATE_KEY=$OPTARG
      ;;
  esac
done

mkdir -p ../_ssh && ssh-keygen -t rsa -b 2048 -N "" -f ../_ssh/id_rsa # Generate ssh key

if [ ~/.ssh/id_rsa ]; then
   mkdir -p ~/.ssh
   cp ../_ssh/id_rsa ~/.ssh/id_rsa
   cp ../_ssh/id_rsa.pub ~/.ssh/id_rsa.pub
fi

cp ../inventory/mycluster ../inventory/mycluster-init
sed -i 's/root/centos/g' ../inventory/mycluster-init

cd ../ 
if [ -z "${PRIVATE_KEY+xxx}" ]; 
then
    ansible-playbook -i inventory/mycluster-init playbooks/copy-ssh-key-id.yaml --ask-pass --ask-su-pass
else
    ansible-playbook -i inventory/mycluster-init playbooks/copy-ssh-key-id.yaml --private-key=$PRIVATE_KEY
fi

# Check connectivity
ansible -i inventory/mycluster -m ping all-vms
cd scripts

# remove temporal init file
rm -f ../inventory/mycluster-init