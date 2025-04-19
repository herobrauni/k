# Cluster Restructuring Notes

## Current Setup
- Cluster runs on k3s on Debian servers.
- VPN connectivity is provided by Tailscale.

## Planned Switch to Talos
- Intend to switch cluster OS to Talos.
- VPN connectivity will switch from Tailscale to Kubespan + Cilium with native routing.

- Considering using Tailscale over Kubespan due to mixed IPv4-only and IPv6-only servers in the cluster.

## Caveats and Configuration Details

### Talos Configuration for Kubespan
```yaml
machine:
  network:
    kubespan:
      enabled: true
      advertiseKubernetesNetworks: true
      allowDownPeerBypass: false
cluster:
  discovery:
    enabled: true
    registries:
      kubernetes: # Kubernetes registry is problematic with KubeSpan if the control plane endpoint is routeable itself via KubeSpan.
        disabled: true
      service: {}
```

### Cilium Installation for Native Routing
```bash
cilium install \
  --set ipam.mode=kubernetes \
  --set kubeProxyReplacement=false \
  --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
  --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
  --set cgroup.autoMount.enabled=false \
  --set cgroup.hostRoot=/sys/fs/cgroup \
  --set routing-mode=native \
  --set ipv4-native-routing-cidr=10.42.0.0/16 \
  --set nodeIPAM.enabled=true \
  --set defaultLBServiceIPAM=nodeipam
```

### DaemonSet Required for Cilium Native Routing

See [cilium-host-node-cidr-daemonset.yaml](./cilium-host-node-cidr-daemonset.yaml) for the full DaemonSet manifest.

### Talos Volume Configuration
```yaml
apiVersion: v1alpha1
kind: VolumeConfig
name: EPHEMERAL
provisioning:
  maxSize: 20GiB
```

### Talos User Volume Configuration
```yaml
apiVersion: v1alpha1
kind: UserVolumeConfig
name: ceph-data
provisioning:
  diskSelector:
    match: system_disk
  minSize: 1GB
```

### Post-Configuration Step
- After creating the user volume, the filesystem on it needs to be destroyed:
```bash
talosctl wipe disk sdxX
```
(Note: Replace `sdxX` with the actual disk identifier.)

### Load Balancer Node IPs Caveat
- To enable Cilium to assign node IPs to load balancers (e.g., Traefik), the label `node.kubernetes.io/exclude-from-external-load-balancers` must be removed from Talos nodes.

## TODO / Research Topics
- Move kubeapi access to be accessible only via Tailscale (possibly using the Tailscale operator).
- Remove Talos kube-proxy and replace it with Cilium kube-proxy.
- Check ports and firewall settings for Talos nodes to ensure proper network security and functionality.
- [ ] Research how to update Talos while keeping Rook Ceph intact (might involve a wipe flag).
- [ ] Research how to reset a Talos node without wiping Rook Ceph data.
- [ ] enable qemu-guest-agent extension?

## Notes
- Kubespan requires specific Talos network config to enable native routing and advertise Kubernetes networks.
- Kubernetes registry discovery must be disabled due to routing issues with Kubespan.
- Cilium must be installed with specific flags to support native routing and node IPAM.
- A DaemonSet is required to manage cilium_host IP addresses for native routing to work properly.
- Talos volume configuration requires setting max size for ephemeral volume and creating a user volume for remaining disk space.
- Wiping the user volume filesystem is necessary after volume creation.
- Removing the exclude-from-external-load-balancers label is necessary for load balancer node IP assignment.

[[debian-k3s-to-talos-migration]]