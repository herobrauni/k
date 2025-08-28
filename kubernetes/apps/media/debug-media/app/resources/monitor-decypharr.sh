#!/bin/bash

# Script to continuously monitor decypharr and media pods
# Compares uptime of each media deployment to decypharr and restarts those with higher uptime
# Monitors: plex, sonarr, sonarr4k, radarr, radarr4k
# Runs in a continuous loop with configurable check intervals
# Usage: ./monitor-decypharr.sh (runs continuously, use Ctrl+C to stop)

NAMESPACE="media"
APP_NAME="decypharr"
TIME_THRESHOLD_MINUTES=5
CHECK_INTERVAL_SECONDS=60
# Deployments to monitor and potentially restart
MONITOR_DEPLOYMENTS=("plex" "sonarr" "sonarr4k" "radarr" "radarr4k")

echo "Starting continuous monitoring of $APP_NAME and media deployments..."
echo "Monitoring deployments: ${MONITOR_DEPLOYMENTS[*]}"
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

# Helper: get uptime in minutes for a deployment
get_deployment_uptime() {
  local deployment_name=$1
  local pod_name=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=$deployment_name -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

  if [ -z "$pod_name" ]; then
    echo "Error: Could not find pod for $deployment_name in namespace $NAMESPACE" >&2
    return 1
  fi

  local start_time=$(kubectl get pod $pod_name -n $NAMESPACE -o jsonpath='{.status.startTime}' 2>/dev/null)

  if [ -z "$start_time" ] || [ "$start_time" == "null" ]; then
    echo "Error: Could not get start time for pod $pod_name" >&2
    return 1
  fi

  local start_time_seconds=$(to_epoch "$start_time")

  if [ -z "$start_time_seconds" ]; then
    echo "Error: Could not parse start time for $deployment_name" >&2
    return 1
  fi

  local uptime_seconds=$((CURRENT_TIME - start_time_seconds))
  local uptime_minutes=$((uptime_seconds / 60))

  echo "$uptime_minutes"
  return 0
}

# Get decypharr uptime first
echo "Getting $APP_NAME uptime..."
DECYPHARR_UPTIME=$(get_deployment_uptime "$APP_NAME")

if [ $? -ne 0 ]; then
    echo "Error: Could not get $APP_NAME uptime"
    iteration_error=true
else
    echo "$APP_NAME uptime: $DECYPHARR_UPTIME minutes"
fi

# Check each deployment and restart those with higher uptime than decypharr
deployments_to_restart=()

for deployment in "${MONITOR_DEPLOYMENTS[@]}"; do
    echo "Checking $deployment uptime..."

    deployment_uptime=$(get_deployment_uptime "$deployment")

    if [ $? -ne 0 ]; then
        echo "Error: Could not get $deployment uptime"
        iteration_error=true
        continue
    fi

    echo "$deployment uptime: $deployment_uptime minutes"

    # Compare uptime with decypharr
    if [ $deployment_uptime -gt $DECYPHARR_UPTIME ]; then
        echo "$deployment has been running longer than $APP_NAME ($deployment_uptime > $DECYPHARR_UPTIME minutes)"
        deployments_to_restart+=("$deployment")
    else
        echo "$deployment uptime ($deployment_uptime minutes) is not longer than $APP_NAME ($DECYPHARR_UPTIME minutes)"
    fi
done

# Restart deployments that need it
if [ ${#deployments_to_restart[@]} -gt 0 ]; then
    echo "Restarting deployments with higher uptime: ${deployments_to_restart[*]}"

    for deployment in "${deployments_to_restart[@]}"; do
        echo "Restarting $deployment deployment..."
        kubectl rollout restart deployment/$deployment -n $NAMESPACE
        if [ $? -eq 0 ]; then
            echo "Successfully initiated $deployment deployment restart"
        else
            echo "Error: Failed to restart $deployment deployment"
            iteration_error=true
        fi
    done
else
    echo "No deployments need restarting - all have lower or equal uptime compared to $APP_NAME"
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
