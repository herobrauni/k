#!/bin/bash

# Script to continuously monitor decypharr and plex pods
# Checks pod uptimes and restarts plex if it's been running longer than decypharr
# Runs in a continuous loop with configurable check intervals
# Usage: ./monitor-decypharr.sh (runs continuously, use Ctrl+C to stop)

NAMESPACE="media"
APP_NAME="decypharr"
OTHER_APP="plex"
TIME_THRESHOLD_MINUTES=5
CHECK_INTERVAL_SECONDS=60

echo "Starting continuous monitoring of $APP_NAME and $OTHER_APP pods..."
echo "Check interval: $CHECK_INTERVAL_SECONDS seconds"
echo "Press Ctrl+C to stop monitoring"
echo

# Main monitoring loop
while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Checking pod statuses..."

    # Reset error flag for this iteration
    iteration_error=false

    echo "Checking if $APP_NAME pod has restarted in the last $TIME_THRESHOLD_MINUTES minutes..."

# Helper: parse RFC3339 time to epoch seconds (GNU date or BSD date fallback)
to_epoch() {
  date -u -d "$1" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$1" +%s 2>/dev/null
}

# Get the pod name for decypharr
POD_NAME=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=$APP_NAME -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$POD_NAME" ]; then
    echo "Error: Could not find pod for $APP_NAME in namespace $NAMESPACE"
    iteration_error=true
fi

echo "Found pod: $POD_NAME"

# Get pod start time
START_TIME=$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.status.startTime}' 2>/dev/null)

if [ -z "$START_TIME" ] || [ "$START_TIME" == "null" ]; then
    echo "Error: Could not get start time for pod $POD_NAME"
    iteration_error=true
fi

echo "Pod start time: $START_TIME"

CURRENT_TIME=$(date -u +%s)
START_TIME_SECONDS=$(to_epoch "$START_TIME")

if [ -z "$START_TIME_SECONDS" ]; then
    echo "Error: Could not parse start time"
    iteration_error=true
fi

# Calculate pod uptime
UPTIME_SECONDS=$((CURRENT_TIME - START_TIME_SECONDS))
UPTIME_MINUTES=$((UPTIME_SECONDS / 60))

echo "Pod uptime: $UPTIME_MINUTES minutes"

# Get the pod name for plex
PLEX_POD_NAME=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=$OTHER_APP -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$PLEX_POD_NAME" ]; then
    echo "Error: Could not find pod for $OTHER_APP in namespace $NAMESPACE"
    iteration_error=true
fi

echo "Found plex pod: $PLEX_POD_NAME"

# Get plex pod start time
PLEX_START_TIME=$(kubectl get pod $PLEX_POD_NAME -n $NAMESPACE -o jsonpath='{.status.startTime}' 2>/dev/null)

if [ -z "$PLEX_START_TIME" ] || [ "$PLEX_START_TIME" == "null" ]; then
    echo "Error: Could not get start time for plex pod $PLEX_POD_NAME"
    iteration_error=true
fi

echo "Plex pod start time: $PLEX_START_TIME"

PLEX_START_TIME_SECONDS=$(to_epoch "$PLEX_START_TIME")

if [ -z "$PLEX_START_TIME_SECONDS" ]; then
    echo "Error: Could not parse plex start time"
    iteration_error=true
fi

# Calculate plex pod uptime
PLEX_UPTIME_SECONDS=$((CURRENT_TIME - PLEX_START_TIME_SECONDS))
PLEX_UPTIME_MINUTES=$((PLEX_UPTIME_SECONDS / 60))

echo "Plex pod uptime: $PLEX_UPTIME_MINUTES minutes"

# Compare uptimes and restart plex if it's been running longer than decypharr
if [ $PLEX_UPTIME_MINUTES -gt $UPTIME_MINUTES ]; then
    echo "Plex has been running longer than decypharr ($PLEX_UPTIME_MINUTES > $UPTIME_MINUTES minutes)"
    echo "Restarting plex pod..."
    kubectl delete pod $PLEX_POD_NAME -n $NAMESPACE
    if [ $? -eq 0 ]; then
        echo "Successfully initiated plex pod restart"
    else
        echo "Error: Failed to restart plex pod"
        iteration_error=true
    fi
else
    echo "Plex uptime ($PLEX_UPTIME_MINUTES minutes) is not longer than decypharr ($UPTIME_MINUTES minutes) - no restart needed"
fi

    # Log iteration result
    if [ "$iteration_error" = true ]; then
        echo "Warning: Errors occurred during this check cycle, but monitoring will continue"
    else
        echo "Check cycle completed successfully"
    fi

    echo "Waiting $CHECK_INTERVAL_SECONDS seconds before next check..."
    echo
    sleep $CHECK_INTERVAL_SECONDS
done
