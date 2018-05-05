#!/bin/bash
cd ../
ansible-playbook -i inventory/mycluster playbooks/k8s-all.yaml