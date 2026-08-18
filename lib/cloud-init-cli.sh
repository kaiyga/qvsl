#!/usr/bin/env bash
set -euo pipefail

cli_add_cloud_init_cdrom() {
    local iso_path="${1:-/vm/disks/cloud-init.iso}"
    echo "-drive file=${iso_path},format=raw,media=cdrom"
}
