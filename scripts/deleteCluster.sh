#!/bin/bash
# This delete kubernetes container cluster
#
# Prerequisite:
# 1. inventory/mycluster must be configured.
# 2. ssh access is set up.
#  2.1. Setup ssh access from master to workers (user: root).
#  2.2 Setup ssh access from first master to the other masters (user: root)

cd ../
ansible-playbook -i inventory/mycluster playbooks/cleanup.yaml