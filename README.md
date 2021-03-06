# Setup Kubernetes HA on CentOS 7 or Redhat Enterprise Linux 7.  

This repository provides Ansible Playbooks To setup Kubernetes HA on Redhat Enterprise Linux 7. The playbooks are mainly inspired by Kubeadm documentation and other ansible tentatives on github. The playbooks could be used separately or as one playbook for a fully fledged HA cluster. 

#Prerequisites: 
1. one or more machines (or VMs) for deploying k8s cluster. 
2. user `centos` is already created, and it privilege for sudo.
2. You have ssh access to `centos` user the machines.
3. You can access to machines with private IP address.

Suppoted OS for machines:
 - CentOS 7
 - RHEL 7.2+ (Only tested on CentOS 7)

Note: Do not install libraries such as docker or firewalld manually, which may cause version dependency errors.

4. Ansible is installed on your laptop.
```
pip install epel-release ansible
```
or
```
brew install ansible
```


# Getting started:
### 1. git clone
 ```
 git clone https://github.com/yabuchan/ansible-kubernetes-ha-cluster.git
 cd ansible-kubernetes-ha-cluster
 ```

### 2. Prepare inventory/mycluster.
##### (Option 1) Use script:
```
cd scripts
./setup-myCluster.sh -m IP_ADDRESS_1,IP_ADDRESS_2 -w IP_ADDRESS_3,IP_ADDRESS_4 -v IP_ADDRESS_5 -i INTERFACE
```
- IP_ADDRESS_1,IP_ADDRESS_2: are ip address of machine to set up as master 
-  IP_ADDRESS_3,IP_ADDRESS_4: are ip address of machine to set up as worker
-  INTERFACE is network interface to be used. You can check your interface by ip a  
Run `./setup-myCluster.sh -h` for more details.
If you install cluster to single machine, include only master.

##### (Option 2) Manually create inventory/mycluster and modify it. 
Declare your machines such as:
```
myhostname.domain.com ansible_usehost=<ip> ansible_user=<user>
```

There are different groups being defined and used, you can reuse mycluster file defined in inventory folder:
```
[all-masters] # these are all the masters
[all-workers] # these are all the worker nodes
[all-vms] # these are all vms of the cluster
```
See inventory/mycluster-sample for more details.

### 3. Setup ssh access.
* Ssh access from master to workers without password or pem file as root user (i.e. ssh root@WORKER_MACHINE from root@MASTER_MACHINE).
* Ssh access from first master to the other masters without password or pem file as root user (i.e. ssh root@WORKER_MACHINE from root@MASTER_MACHINE).

There are two options:
##### (Option 1) Do it manually using copy-ssh-id. ref: https://www.ssh.com/ssh/copy-id
You can check that you can ping all the machines:
```
ansible -m ping all -i inventory/mycluster
```

##### (Option 2) Use script:
In this option, user: `centos` has been already created and `centos` user is in wheel group (i.e. `centos` can exec sudo).
```
cd scripts
./set-ssh-key.sh -k ~/.ssh/hoge.hoge.pem
```
Run `./set-ssh-key.sh -h` for more details.

### 3. Launch up k8s cluster:
```
cd scripts
./createCluster.sh
```

This script does:
- Installing docker
- Generating etcd certificates and installing ha etcd cluster on all the master nodes
- Installing keepalived and setting up vip management
- Installing kubeadm, kubelet and kubectl
- Setting up kubernetes masters
- Adding the nodes to the cluster
- Reconfiguring the nodes and components to use the vip

### 4. Enjoy you k8s!
Your kubeconfig is stored as `/etc/kubernetes/admin.conf` in first master node.
Copy & set your environment kubeconfig. Ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/#set-the-kubeconfig-environment-variable

# Delete your cluster:
```
cd scripts
./deleteCluster.sh
```

# Encrypting Secrets at rest:
If you want to add an extra layer of securing your secrets by encrypting them at rest you can use the "encrypting-secrets.yaml playbook". You can add it to the k8s-all.yaml or use it separately.

Before using it, update the inventory file to change the encryption key variable "encoded_secret".
To generate a new encryption key you can do the following:

```
head -c 32 /dev/urandom | base64
```
Copy the output and save it in the inventory variable.

After that run the playbook:

```
ansible-playbook -i inventory/mycluster  playbooks/encrypting-secrets.yaml
```

