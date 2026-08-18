#!/usr/bin/env bash
set -euo pipefail

cli_add_bridge_network() {
    local idx="$1"
    local bridge_if="$2"
    local vm_name="$3"
    echo "-netdev tap,id=net${idx},ifname=tap${idx}-${vm_name},script=no,downscript=no -device virtio-net-pci,netdev=net${idx}"
}

cli_add_nat_network() {
    local idx="$1"
    local fwd_rules="$2"
    echo "-netdev user,id=net${idx}${fwd_rules} -device virtio-net-pci,netdev=net${idx}"
}
