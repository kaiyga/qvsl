#!/usr/bin/env bash
set -euo pipefail

cli_add_disk() {
    local drive_path="$1"
    local format="$2"
    echo "-drive file=${drive_path},format=${format},if=virtio"
}

cli_add_cdrom() {
    local iso_path="$1"
    echo "-drive file=${iso_path},format=raw,media=cdrom"
}
