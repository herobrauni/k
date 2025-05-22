#!/bin/bash

# Simple script to find and replace strings in files

# Define search and replace patterns
PATTERNS=(
    "devbu.io:480p.com"
    "devbu-io:480p-com"
    "America/New_York:Europe/Berlin"
    "ceph-block:longhorn"
    "rook-ceph-cluster:longhorn"
    "rook-ceph:longhorn-system"
    "onepassword:bitwarden-secretsmanager"
)

# Get the root directory of the git repository
ROOT_DIR="$(git rev-parse --show-toplevel)"

echo "Starting search and replace operations..."
echo "Root directory: $ROOT_DIR"

# Process each pattern
for pattern_pair in "${PATTERNS[@]}"; do
    # Split the pattern pair into search and replace
    search="${pattern_pair%%:*}"
    replace="${pattern_pair##*:}"

    echo "Processing pattern: '$search' -> '$replace'"

    # Find files containing the pattern, excluding scripts directory
    files=$(grep -l -r "$search" "$ROOT_DIR" --include="*.yaml" --include="*.yml" --include="*.json" --include="*.md" --exclude-dir="scripts" 2>/dev/null || true)

    if [ -z "$files" ]; then
        echo "No files found containing pattern: $search"
        continue
    fi

    # Process each file
    for file in $files; do
        # Skip files that are not regular files or are not writable
        if [ ! -f "$file" ] || [ ! -w "$file" ]; then
            echo "Skipping file (not a regular file or not writable): $file"
            continue
        fi

        # Skip files that are in .git directory or scripts directory
        if [[ "$file" == *"/.git/"* ]] || [[ "$file" == */scripts/* ]]; then
            echo "Skipping file in .git or scripts directory: $file"
            continue
        fi

        # Count occurrences before replacement
        count=$(grep -c "$search" "$file" 2>/dev/null || echo 0)

        if [ "$count" -gt 0 ]; then
            # Perform replacement
            sed -i "s|$search|$replace|g" "$file" 2>/dev/null
            echo "Replaced pattern in file: $file ($count occurrences)"
        fi
    done
done

echo "Search and replace operations completed successfully"