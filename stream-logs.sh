#!/usr/bin/env bash

ARGS=()

set -euo pipefail

while [ $# -gt 0 ]; do
    ARGS+=("$1")
    shift
done

run() {
    set -euo pipefail
    local remote="$1"
    local host="${remote%%:*}"
    local file="${remote#*:}"
    local base
    local size
    base="$(basename "$file")"
    local target="${host}_${base}"
    rsync -P --no-whole-file "$remote" "$target"
    size="$(wc -c "$target" | awk '{print $1}')"
    echo "Streaming $target..."
    ssh "$host" tail -c "+$size" -f "$file" >> "$target"
}

export -f run

printf "%s\0" "${ARGS[@]}" | xargs -0 -P99 -I{} bash -c 'run "{}"'