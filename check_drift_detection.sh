#!/bin/bash

# Find all helmrelease.yaml files
echo "Checking all helmrelease.yaml files for drift detection configuration..."
echo ""

# Store the list of files
files=$(find kubernetes -name "helmrelease.yaml")

# Initialize counters
total=0
with_drift=0
without_drift=0

# Check each file
for file in $files; do
  total=$((total + 1))

  # Check if the file contains the drift detection configuration
  if grep -A 1 "driftDetection:" "$file" | grep -q "mode: enabled"; then
    echo "✅ $file has drift detection enabled"
    with_drift=$((with_drift + 1))
  else
    echo "❌ $file does NOT have drift detection enabled"
    without_drift=$((without_drift + 1))
  fi
done

# Print summary
echo ""
echo "Summary:"
echo "-------"
echo "Total helmrelease.yaml files: $total"
echo "Files with drift detection enabled: $with_drift"
echo "Files without drift detection enabled: $without_drift"