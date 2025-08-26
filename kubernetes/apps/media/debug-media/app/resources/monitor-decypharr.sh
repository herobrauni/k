#!/bin/bash

# Script to check if decypharr pod has restarted in the last 5 minutes
# Also checks how long the pod has been running
# If decypharr restarted recently, compare with plex restarts and restart plex if needed
# Usage: ./monitor-decypharr.sh

NAMESPACE="media"
APP_NAME="decypharr"
OTHER_APP="plex"
TIME_THRESHOLD_MINUTES=5

echo "Checking if $APP_NAME pod has restarted in the last $TIME_THRESHOLD_MINUTES minutes..."

# Helper: parse RFC3339 time to epoch seconds (GNU date or BSD date fallback)
to_epoch() {
  date -u -d "$1" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$1" +%s 2>/dev/null
}

# Get the pod name for decypharr
POD_NAME=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=$APP_NAME -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$POD_NAME" ]; then
    echo "Error: Could not find pod for $APP_NAME in namespace $NAMESPACE"
    exit 1
fi

echo "Found pod: $POD_NAME"

# Get pod start time
START_TIME=$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.status.startTime}' 2>/dev/null)

if [ -z "$START_TIME" ] || [ "$START_TIME" == "null" ]; then
    echo "Error: Could not get start time for pod $POD_NAME"
    exit 1
fi

echo "Pod start time: $START_TIME"

CURRENT_TIME=$(date -u +%s)
START_TIME_SECONDS=$(to_epoch "$START_TIME")

if [ -z "$START_TIME_SECONDS" ]; then
    echo "Error: Could not parse start time"
    exit 1
fi

# Calculate pod uptime
UPTIME_SECONDS=$((CURRENT_TIME - START_TIME_SECONDS))
UPTIME_MINUTES=$((UPTIME_SECONDS / 60))

echo "Pod uptime: $UPTIME_MINUTES minutes"

# If pod started recently, just report and exit 0 per your preference
if [ $UPTIME_MINUTES -lt $TIME_THRESHOLD_MINUTES ]; then
    echo "Pod started recently (within last $TIME_THRESHOLD_MINUTES minutes)"
    exit 0
fi

# Get decypharr last restart time (if any)
DECY_LAST_RESTART_TIME=$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.status.containerStatuses[0].lastState.terminated.finishedAt}' 2>/dev/null)
DECY_RESTART_COUNT=$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null || echo 0)

echo "Decypharr restart count: ${DECY_RESTART_COUNT}"
if [ -z "$DECY_LAST_RESTART_TIME" ] || [ "$DECY_LAST_RESTART_TIME" == "null" ]; then
    echo "No recent restart detected for $APP_NAME pod"
    exit 0
fi

echo "Decypharr last restart time: $DECY_LAST_RESTART_TIME"

DECY_LAST_RESTART_SECONDS=$(to_epoch "$DECY_LAST_RESTART_TIME")
if [ -z "$DECY_LAST_RESTART_SECONDS" ]; then
    echo "Error: Could not parse decypharr last restart time"
    exit 1
fi

TIME_DIFF_SECONDS=$((CURRENT_TIME - DECY_LAST_RESTART_SECONDS))
TIME_DIFF_MINUTES=$((TIME_DIFF_SECONDS / 60))

echo "Time since decypharr last restart: $TIME_DIFF_MINUTES minutes"

# If decypharr restarted within threshold, check plex
if [ $TIME_DIFF_MINUTES -le $TIME_THRESHOLD_MINUTES ]; then
    echo "Decypharr restarted within the last $TIME_THRESHOLD_MINUTES minutes — checking $OTHER_APP restarts..."

    # Find plex pods
    PLEX_PODS=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=$OTHER_APP -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
    if [ -z "$PLEX_PODS" ]; then
        echo "Warning: No pods found for $OTHER_APP in namespace $NAMESPACE. Skipping restart."
        exit 0
    fi

    # For each plex pod, compute the most recent restart time (or startTime if never restarted)
    MAX_PLEX_RESTART_SECONDS=0
    for p in $PLEX_PODS; do
        plex_last=$(kubectl get pod $p -n $NAMESPACE -o jsonpath='{.status.containerStatuses[0].lastState.terminated.finishedAt}' 2>/dev/null)
        if [ -z "$plex_last" ] || [ "$plex_last" == "null" ]; then
            # fall back to pod startTime
            plex_last=$(kubectl get pod $p -n $NAMESPACE -o jsonpath='{.status.startTime}' 2>/dev/null)
        fi

        if [ -z "$plex_last" ] || [ "$plex_last" == "null" ]; then
            # no usable timestamp, skip
            echo "Pod $p: no restart or start time available"
            continue
        fi

        plex_seconds=$(to_epoch "$plex_last")
        if [ -z "$plex_seconds" ]; then
            echo "Warning: could not parse time for plex pod $p ($plex_last)"
            continue
        fi

        if [ "$plex_seconds" -gt "$MAX_PLEX_RESTART_SECONDS" ]; then
            MAX_PLEX_RESTART_SECONDS=$plex_seconds
        fi
    done

    if [ "$MAX_PLEX_RESTART_SECONDS" -eq 0 ]; then
        echo "No plex timestamps found; assuming plex has not restarted since decypharr. Triggering rollout restart of deployment/$OTHER_APP."
        kubectl rollout restart deployment/$OTHER_APP -n $NAMESPACE && echo "Triggered rollout restart for $OTHER_APP" || echo "Failed to trigger rollout restart for $OTHER_APP"
        exit 0
    fi

    echo "Most recent plex restart/start time (epoch): $MAX_PLEX_RESTART_SECONDS"
    echo "Decypharr last restart time (epoch): $DECY_LAST_RESTART_SECONDS"

    if [ "$MAX_PLEX_RESTART_SECONDS" -gt "$DECY_LAST_RESTART_SECONDS" ]; then
        echo "Plex has been restarted after decypharr; no action needed."
        exit 0
    else
        echo "Plex has NOT been restarted after decypharr. Triggering rollout restart of deployment/$OTHER_APP..."
        kubectl rollout restart deployment/$OTHER_APP -n $NAMESPACE && echo "Triggered rollout restart for $OTHER_APP" || echo "Failed to trigger rollout restart for $OTHER_APP"
        exit 0
    fi
else
    echo "Decypharr did not restart within the last $TIME_THRESHOLD_MINUTES minutes. No action."
    exit 0
fi
