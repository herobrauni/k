#!/bin/bash

# Debug script for decypharr-sync-helper ExternalSecret issue
echo "=== Debugging ExternalSecret for decypharr-sync-helper ==="
echo ""

# Check if the ExternalSecret exists
echo "1. Checking if ExternalSecret exists in media namespace:"
kubectl get externalsecret decypharr-sync-helper -n media -o yaml || echo "ExternalSecret not found!"
echo ""

# Check if the target secret exists
echo "2. Checking if target secret decypharr-sync-helper-secret exists:"
kubectl get secret decypharr-sync-helper-secret -n media -o yaml || echo "Target secret not found!"
echo ""

# Check ExternalSecret status
echo "3. Checking ExternalSecret status:"
kubectl describe externalsecret decypharr-sync-helper -n media
echo ""

# Check ClusterSecretStore status
echo "4. Checking ClusterSecretStore status:"
kubectl get clustersecretstore bitwarden-secretsmanager -o yaml
echo ""

# Check related working ExternalSecrets for comparison
echo "5. Checking working ExternalSecret (decypharr) for comparison:"
kubectl get externalsecret decypharr -n media -o yaml | head -20
echo ""

# Check Flux Kustomization status
echo "6. Checking Flux Kustomization status:"
kubectl get kustomization decypharr-sync-helper -n flux-system -o yaml
echo ""

# Check for any events related to the ExternalSecret
echo "7. Checking for recent events in media namespace:"
kubectl get events -n media --sort-by='.lastTimestamp' | grep -i "externalsecret\|secret" | tail -10
echo ""

echo "=== Debugging complete ==="