# Cluster Bootstrap Guide

This document keeps track of the steps to bootstrap the Kubernetes cluster

## 1. Talos Nodes Preparation

### Prerequisites
- Access to all nodes (IPMI/console recommended)

### Steps
1. boot to talos with:
```bash
curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh || wget -O reinstall.sh $_
bash reinstall.sh netboot.xyz
```
2. Prepare Talos configuration files by generating Talos configs using `talhelper`:
```bash
talhelper genconfig -c talos/talconfig.yaml -s talos/talsecret.sops.yaml
```
   This command generates the necessary Talos configuration files for the cluster nodes based on the cluster config and secret files.
3. Bootstrap the talos nodes and get the kubeconfig:
```bash
th gencommand -c talos/talconfig.yaml bootstrap
th gencommand kubeconfig -c talos/talconfig.yaml
```
4.  check health of talos and kubernetes
5. run `scripts/bootstrap-apps.sh`