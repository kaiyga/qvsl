#!/usr/bin/env bash
set -euo pipefail
download_if_url() {
    local source="$1"
    local target_path="$2"

    if [[ "$source" =~ ^https?:// ]]; then
        if [[ -f "$target_path" ]]; then
            echo "--> [HTTP Source] Using cached file: $target_path"
            return 0
        fi

        echo "--> [HTTP Source] Downloading resource from $source ..."
        mkdir -p "$(dirname "$target_path")"
        
        local tmp_file="${target_path}.tmp"
        
        if curl -L --fail --retry 3 -o "$tmp_file" "$source"; then
            mv "$tmp_file" "$target_path"
            echo "--> [HTTP Source] Download complete: $target_path"
        else
            echo "ERROR: Failed to download $source" >&2
            rm -f "$tmp_file"
            return 1
        fi
    fi
}
