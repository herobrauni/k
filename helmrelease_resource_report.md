# HelmRelease Resource Request and Limit Report

This report summarizes the presence of CPU and memory resource requests and limits within the HelmRelease files found in the `kubernetes/apps/` directory.

**Note:** This updated report includes actual resource usage data collected from the cluster using `kubectl top pods --all-namespaces`. The usage data reflects what the applications currently use, while the recommendations suggest what the resource limits should be set to for optimal performance and stability.

## Summary of Findings

### HelmReleases with Resource Requests and Limits Set:

*   `kubernetes/apps/observability/kube-prometheus-stack/app/helmrelease.yaml` (for `prometheusSpec`)
*   `kubernetes/apps/authentik/authentik/app/helmrelease.yaml` (for `server`)
    - Current Usage: CPU ~10m, Memory ~363Mi (average of pods)
    - Recommended Limits: CPU 40m, Memory 512Mi
*   `kubernetes/apps/media/huntarr/app/helmrelease.yaml` (for `app` container)
    - Current Usage: CPU 1m, Memory 31Mi
    - Recommended Limits: CPU 5m, Memory 64Mi
*   `kubernetes/apps/media/profilarr/app/helmrelease.yaml` (for `app` container)
    - Current Usage: CPU 6m, Memory 60Mi
    - Recommended Limits: CPU 10m, Memory 128Mi
*   `kubernetes/apps/media/huntarr4k/app/helmrelease.yaml` (for `app` container)
    - Current Usage: CPU 1m, Memory 27Mi
    - Recommended Limits: CPU 5m, Memory 64Mi
*   `kubernetes/apps/media/warp/app/helmrelease.yaml` (for `warp` container)
    - Current Usage: CPU 0m, Memory 32Mi
    - Recommended Limits: CPU 5m, Memory 64Mi
*   `kubernetes/apps/media/radarr4k/app/helmrelease.yaml` (for `app` container)
    - Current Usage: CPU 2m, Memory 133Mi
    - Recommended Limits: CPU 10m, Memory 256Mi
*   `kubernetes/apps/media/tautulli/app/helmrelease.yaml` (for `app` container)
    - Current Usage: CPU 1m, Memory 68Mi
    - Recommended Limits: CPU 5m, Memory 128Mi
*   `kubernetes/apps/media/sonarr4k/app/helmrelease.yaml` (for `app` container)
    - Current Usage: CPU 2m, Memory 182Mi
    - Recommended Limits: CPU 20m, Memory 256Mi
*   `kubernetes/apps/observability/gatus/app/helmrelease.yaml` (for `init-config` and `app` containers)
*   `kubernetes/apps/observability/kromgo/app/helmrelease.yaml` (for `app` container)
*   `kubernetes/apps/media/prowlarr/app/helmrelease.yaml` (for `git` and `app` containers)
*   `kubernetes/apps/media/bazarr/app/helmrelease.yaml` (for `app` and `subcleaner` containers)
*   `kubernetes/apps/media/radarr/app/helmrelease.yaml` (for `app` container)
    - Current Usage: CPU 48m, Memory 131Mi
    - Recommended Limits: CPU 100m, Memory 256Mi
*   `kubernetes/apps/media/sonarr/app/helmrelease.yaml` (for `app` container)
    - Current Usage: CPU 2m, Memory 289Mi
    - Recommended Limits: CPU 120m, Memory 512Mi
*   `kubernetes/apps/media/debug-media/app/helmrelease.yaml` (for `app` container)
*   `kubernetes/apps/network/echo/app/helmrelease.yaml` (for `app` container)
    - Current Usage: CPU 1m, Memory 46Mi
    - Recommended Limits: CPU 5m, Memory 128Mi

### HelmReleases with Only Resource Requests Set (or limits empty):

*   `kubernetes/apps/rook-ceph/rook-ceph/app/helmrelease.yaml` (requests set, limits empty)
*   `kubernetes/apps/rook-ceph/rook-ceph/cluster/helmrelease.yaml` (requests set for `osd` and `exporter`, no limits)
*   `kubernetes/apps/media/autosync/app/helmrelease.yaml` (requests set for `app` container, no limits)
    - Current Usage: CPU 2m, Memory 54Mi
    - Recommended Limits: CPU 10m, Memory 128Mi
*   `kubernetes/apps/media/recyclarr/app/helmrelease.yaml` (requests set for `app` container, no limits)

### HelmReleases with Commented-Out Resources:

*   `kubernetes/apps/media/plex/app/helmrelease.yaml`
    - Current Usage: CPU 2m, Memory 98Mi
    - Recommended Limits: CPU 10m, Memory 256Mi
*   `kubernetes/apps/media/decypharr/app/helmrelease.yaml`
    - Current Usage: CPU 12m, Memory 80Mi
    - Recommended Limits: CPU 20m, Memory 128Mi
*   `kubernetes/apps/media/rdtclient/app/helmrelease.yaml`

### HelmReleases Using `valuesFrom` ConfigMap (Resource limits might be defined there):

*   `kubernetes/apps/kube-system/spegel/app/helmrelease.yaml`
*   `kubernetes/apps/flux-system/flux-instance/app/helmrelease.yaml`
*   `kubernetes/apps/cert-manager/cert-manager/app/helmrelease.yaml`
*   `kubernetes/apps/kube-system/cilium/app/helmrelease.yaml`
*   `kubernetes/apps/flux-system/flux-operator/app/helmrelease.yaml`
*   `kubernetes/apps/kube-system/coredns/app/helmrelease.yaml`

### HelmReleases with No Explicit Resource Requests or Limits Found:

*   `kubernetes/apps/muse/muse/app/helmrelease.yaml`
    - Current Usage: CPU 1m, Memory 116Mi
    - Recommended Limits: CPU 5m, Memory 256Mi
*   `kubernetes/apps/nfs-ganesha/nfs-ganesha/app/helmrelease.yaml`
    - Current Usage: CPU 1m, Memory 151Mi
    - Recommended Limits: CPU 5m, Memory 256Mi
*   `kubernetes/apps/observability/alloy/app/helmrelease.yaml`
*   `kubernetes/apps/tailscale-operator/tailscale-operator/app/helmrelease.yaml`
*   `kubernetes/apps/debug/debug/app/helmrelease.yaml`
*   `kubernetes/apps/media/plex/tools/off-deck/helmrelease.yaml`
*   `kubernetes/apps/observability/grafana/app/helmrelease.yaml` (for the main Grafana deployment)
*   `kubernetes/apps/observability/loki/app/helmrelease.yaml`
*   `kubernetes/apps/observability/promtail/app/helmrelease.yaml`
*   `kubernetes/apps/external-secrets/external-secrets/app/helmrelease.yaml`
*   `kubernetes/apps/kube-system/flannel/app/helmrelease.yaml`
*   `kubernetes/apps/kube-system/headlamp/app/helmrelease.yaml`
*   `kubernetes/apps/zurg/zurg/app/helmrelease.yaml`
*   `kubernetes/apps/network/traefik/app/helmrelease.yaml`
*   `kubernetes/apps/kube-system/snapshot-controller/app/helmrelease.yaml`
*   `kubernetes/apps/kube-system/node-feature-discovery/app/helmrelease.yaml`
*   `kubernetes/apps/kube-system/intel-device-plugin-operator/gpu/helmrelease.yaml`
*   `kubernetes/apps/kube-system/intel-device-plugin-operator/app/helmrelease.yaml`
*   `kubernetes/apps/kube-system/reloader/app/helmrelease.yaml`
*   `kubernetes/apps/kube-system/descheduler/app/helmrelease.yaml`
*   `kubernetes/apps/kube-system/metrics-server/app/helmrelease.yaml`
*   `kubernetes/apps/system-upgrade/system-upgrade-controller/app/helmrelease.yaml`

---

**Recommendations:**

- Recommended limits are generally set to about 2x the observed peak usage to allow for headroom and burst capacity.
- For apps with very low usage, minimal limits are suggested to avoid resource starvation.
- It is advised to monitor resource usage continuously and adjust limits accordingly.