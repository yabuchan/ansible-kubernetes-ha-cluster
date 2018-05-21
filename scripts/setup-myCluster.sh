#!/bin/bash
# setup-myCluster create myCluster
# Only centos 7 is supported, although it may work by slightly changing roles/copy-ssh-key-id.

INVENTORY=../inventory/mycluster

while getopts "m:o:v:w:i:c:h" arg; do
  case $arg in
    h | --help)
      echo -e "Style:";
      echo -e "  setup-myCluster.sh -m IP_A,IP_B -w IP_C,IP_D,IP_E -v IP_F -i eth1\n"; 
      echo -e "Example:";
      echo -e "  setup-myCluster.sh -m 172.16.0.1,172.16.0.2 -w 172.16.0.3,172.16.0.4 -v 172.16.0.100 \n"; 
      echo -e "Required Params:";
      echo -e "    -m      Comma seperated list of IP address to install k8s master.";
      echo -e "    -v      Virtual IP address of k8s master. i.e. IP address of loadbalancer of k8s master. If no balancer exists set one of master's IP address.\n";
      echo -e "Options:";
      echo -e "    -w      Comma seperated list of IP address to install k8s worker.";
      echo -e "    -i      network interface name. Default is eth0.";
      echo -e "    -c      cidr of overlayed network for containers. Default is 10.0.0.0/16.";
      echo -e "    -h      help"; 
      exit 0 
      ;;
    m)
      MASTERS=$OPTARG
      ;;
    w)
      WORKERS=$OPTARG
      ;;
    v)
      VIP=$OPTARG
      ;;
    i)
      NIF=$OPTARG
      ;;
    c)
      CIDR=$OPTARG
      ;;
  esac
done

if [ -z "${MASTERS+xxx}" ]; then
    echo -e "Master nodes must be included. Please type list of IP address, splitted by comma: "
    echo "(e.g. 172.16.0.1,172.16.0.2)"
    read MASTERS
    echo "master IP address: $MASTERS"
fi

if [ -z "${VIP+xxx}" ]; then
    echo -e "Virtual IP must be included. Please type an IP address."
    echo "(e.g. 172.16.0.100)"
    read VIP
    echo "worker IP address: $WORKERS"
fi

if [ -z "${NIF+xxx}" ]; then
    echo -e "eht0 (default) is used for network interface.\n"
    NIF=eth0
fi

if [ -z "${CIDR+xxx}" ]; then
    echo -e "10.0.0.0/16 (default) is used for overlayed pod network.\n"
    CIDR=10.0.0.0/16
fi



function setTarget()
{ 
  IFS=', ' read -r -a targetArr <<< "$1"
  for target in "${targetArr[@]}"
  do
      echo "$target ansible_usehost=$target ansible_user=root" >> $INVENTORY
  done
}

echo "[all-vms]" > $INVENTORY
setTarget "$MASTERS"
setTarget "$WORKERS"

echo -e "\n[all-masters]" >> $INVENTORY
setTarget "$MASTERS"

echo -e "\n[all-workers]" >> $INVENTORY
setTarget "$WORKERS"

cat <<EOT >> $INVENTORY
[all-masters:vars]
kubernetes_version=1.10.0
kubelet_version=1.10.0-0
kubeadm_version=1.10.0
etcd_version=v3.1.12
pod_network_cidr=${CIDR}
virtual_ip=${VIP}
network_interface=<${NIF}>
smoke_test_node_port=31111
service-node-port-range=30000-32767

[all-vms:vars]
virtual_ip=${VIP}
kubelet_version=1.9.6-0
service-node-port-range=30000-32767
EOT
