#!/usr/bin/env bash
set -euo pipefail

mgr_prepare_bridge_net() {
    local idx="$1"
    local bridge_if="$2"
    local tap_if="tap${idx}"

    echo "--> [Network Mgr] Checking bridge interface $bridge_if for TAP $tap_if..."
    
    if [ -d "/sys/class/net/$bridge_if" ]; then
        echo "--> [Network Mgr] Bridge $bridge_if is present."
    else
        echo "WARNING: Bridge $bridge_if not found on host/container network namespace!" >&2
    fi
}

mgr_prepare_nat_net() {
    local idx="$1"
    echo "--> [Network Mgr] User/NAT network #$idx ready."
}
