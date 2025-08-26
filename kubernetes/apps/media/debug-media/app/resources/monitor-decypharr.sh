#!/bin/bash

# Script to check if decypharr pod has restarted in the last 5 minutes
# Usage: ./monitor-decypharr.sh

NAMESPACE="media"
APP_NAME="decypharr"
TIME_THRESHOLD_MINUTES=5

echo "Checking if $APP_NAME pod has restarted in the last $TIME_THRESHOLD_MINUTES minutes..."

# Get the pod name
POD_NAME=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=$APP_NAME -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$POD_NAME" ]; then
    echo "Error: Could not find pod for $APP_NAME in namespace $NAMESPACE"
    exit 1
fi

echo "Found pod: $POD_NAME"

# Get container restart count and last restart time
RESTART_COUNT=$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null)
LAST_RESTART_TIME=$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.status.containerStatuses[0].lastState.terminated.finishedAt}' 2>/dev/null)

echo "Current restart count: $RESTART_COUNT"

if [ -z "$LAST_RESTART_TIME" ] || [ "$LAST_RESTART_TIME" == "null" ]; then
    echo "No recent restart detected for $APP_NAME pod"
    exit 0
fi

echo "Last restart time: $LAST_RESTART_TIME"

# Convert times to seconds since epoch
CURRENT_TIME=$(date -u +%s)
LAST_RESTART_SECONDS=$(date -d "$LAST_RESTART_TIME" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$LAST_RESTART_TIME" +%s 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "Error: Could not parse last restart time"
    exit 1
fi

# Calculate time difference in minutes
TIME_DIFF_SECONDS=$((CURRENT_TIME - LAST_RESTART_SECONDS))
TIME_DIFF_MINUTES=$((TIME_DIFF_SECONDS / 60))

echo "Time since last restart: $TIME_DIFF_MINUTES minutes"

if [ $TIME_DIFF_MINUTES -le $TIME_THRESHOLD_MINUTES ]; then
    echo "ALERT: $APP_NAME pod restarted within the last $TIME_THRESHOLD_MINUTES minutes!"
    exit 1
else
    echo "No recent restart (within last $TIME_THRESHOLD_MINUTES minutes) detected for $APP_NAME pod"
    exit 0
fi
