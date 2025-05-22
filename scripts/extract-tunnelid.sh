#!/usr/bin/env bash

# Script to extract TunnelID from cloudflare-tunnel.json
# and create a Kubernetes secret with CLOUDFLARE_TUNNEL_ID in the 'network' namespace

set -e

JSON_FILE="cloudflare-tunnel.json"
SECRET_NAME="cloudflare-tunnel-id-secret"
NAMESPACE="network"

# Extract TunnelID
if command -v jq &> /dev/null; then
  TUNNEL_ID=$(jq -r '.TunnelID' "$JSON_FILE")
else
  TUNNEL_ID=$(grep -o '"TunnelID":"[^"]*"' "$JSON_FILE" | sed 's/.*"TunnelID":"\([^"]*\)".*/\1/')
fi

if [[ -z "$TUNNEL_ID" ]]; then
  echo "Error: TunnelID not found in $JSON_FILE" >&2
  exit 1
fi

echo "TunnelID: $TUNNEL_ID"

# Create or update the Kubernetes secret in the 'network' namespace
kubectl create secret generic "$SECRET_NAME" \
  --from-literal=CLOUDFLARE_TUNNEL_ID="$TUNNEL_ID" \
  --namespace "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Kubernetes secret '$SECRET_NAME' created/updated in namespace '$NAMESPACE' with CLOUDFLARE_TUNNEL_ID."