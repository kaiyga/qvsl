#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "${BASH_SOURCE[0]}")/http-source.sh"

mgr_setup_cloud_init() {
    local user_data="$1"
    local net_config="${2:-}"
    local meta_data="${3:-}"
    local vm_name="${4:-vm}"
    
    local ci_iso="/vm/disks/cloud-init.iso"
    local init_flag="/vm/disks/.cloud-init.done"

    if [ ! -f "$init_flag" ] || [ ! -f "$ci_iso" ]; then
        echo "--> [Cloud-Init Mgr] Initializing seed ISO generation..."

        local ci_dir
        ci_dir=$(mktemp -d /tmp/cidata.XXXXXX)

        cp "$user_data" "$ci_dir/user-data"

        if [ -n "$meta_data" ] && [ -f "$meta_data" ]; then
            cp "$meta_data" "$ci_dir/meta-data"
        else
            cat <<EOF > "$ci_dir/meta-data"
instance-id: ${vm_name}-static-id
local-hostname: ${vm_name}
EOF
        fi

        if [ -n "$net_config" ] && [ -f "$net_config" ]; then
            echo "--> [Cloud-Init Mgr] Including network-config into ISO..."
            cp "$net_config" "$ci_dir/network-config"
        fi

        local geniso_args=("-output" "$ci_iso" "-volid" "cidata" "-J" "-R")
        geniso_args+=("$ci_dir/user-data" "$ci_dir/meta-data")
        [ -f "$ci_dir/network-config" ] && geniso_args+=("$ci_dir/network-config")

        genisoimage "${geniso_args[@]}" > /dev/null 2>&1

        rm -rf "$ci_dir"
        touch "$init_flag"
        echo "--> [Cloud-Init Mgr] Seed ISO generated at $ci_iso"
    fi
}
