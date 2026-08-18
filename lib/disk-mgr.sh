#!/usr/bin/env bash
set -euo pipefail

. /app/lib/http-source.sh

# Template Initializers

template_init_file() {
    local target_path="$1"
    local source_template="$2"
    local mode="${3:-linked}"
    local template_fmt="${4:-qcow2}"

    if [[ "$source_template" =~ ^https?:// ]]; then
        local ext="qcow2"
        [ "$template_fmt" = "raw" ] && ext="raw"
        
        local cache_file="/vm/disks/.cache_$(echo -n "$source_template" | md5sum | awk '{print $1}').${ext}"
        
        download_if_url "$source_template" "$cache_file"
        source_template="$cache_file"
    fi

    if [ ! -f "$source_template" ] && [ ! -b "$source_template" ]; then
        echo "ERROR: Base template image '$source_template' not found!" >&2
        exit 1
    fi

    mkdir -p "$(dirname "$target_path")"

    if [ "$mode" = "linked" ]; then
        echo "--> [Storage] Creating LINKED qcow2 image (backing fmt: $template_fmt) from: $source_template"
        qemu-img create -f qcow2 -b "$source_template" -F "$template_fmt" "$target_path"
        
    elif [ "$mode" = "full" ]; then
        echo "--> [Storage] Creating FULL COPY from: $source_template..."
        qemu-img convert -p -f "$template_fmt" -O qcow2 "$source_template" "$target_path"
        
    else
        echo "ERROR: Unknown template mode '$mode' for file disk!" >&2
        exit 1
    fi
}

template_init_device() {
    local target_dev="$1"
    local source_template="$2"
    local mode="${3:-full}"
    local template_fmt="${4:-qcow2}"

    if [ ! -b "$target_dev" ]; then
        echo "ERROR: Target block device '$target_dev' does not exist!" >&2
        exit 1
    fi

    if [[ "$source_template" =~ ^https?:// ]]; then
        local ext="qcow2"
        [ "$template_fmt" = "raw" ] && ext="raw"
        local cache_file="/vm/disks/.cache_$(echo -n "$source_template" | md5sum | awk '{print $1}').${ext}"
        download_if_url "$source_template" "$cache_file"
        source_template="$cache_file"
    fi

    if [ "$mode" = "full" ]; then
        echo "--> [Storage] Writing template ($template_fmt) to block device $target_dev..."
        qemu-img convert -p -f "$template_fmt" -O raw "$source_template" "$target_dev"
    else
        echo "ERROR: Unsupported mode '$mode' for raw block device! (Use mode='full')" >&2
        exit 1
    fi
}

# 
# Helper Functions
# 

resize_disk_if_needed() {
    local drive_path="$1"
    local target_size="$2"

    [ -z "$target_size" ] && return 0

    local current_size_bytes
    current_size_bytes=$(qemu-img info --output=json "$drive_path" | grep -o '"virtual-size": [0-9]*' | awk '{print $2}')
    
    local target_size_bytes
    target_size_bytes=$(numfmt --from=iec "$target_size")

    if [ "$target_size_bytes" -gt "$current_size_bytes" ]; then
        echo "--> [Storage] Resizing disk $drive_path to $target_size..."
        qemu-img resize "$drive_path" "$target_size"
    fi
}

# 
# Internal Specific Handlers
# 

mgr_ensure_file_disk() {
    local drive_path="$1"
    local format="$2"
    local size="$3"
    local template_source="${4:-}"
    local template_mode="${5:-linked}"
    local template_format="${6:-qcow2}"

    if [ ! -f "$drive_path" ]; then
        if [ -n "$template_source" ]; then
            template_init_file "$drive_path" "$template_source" "$template_mode" "$template_format"
        else
            echo "--> [Storage] Creating empty $size $format disk: $drive_path"
            mkdir -p "$(dirname "$drive_path")"
            qemu-img create -f "$format" "$drive_path" "$size"
        fi
    else
        echo "--> [Storage] Using existing disk image: $drive_path"
    fi

    if [ -n "$size" ]; then
        resize_disk_if_needed "$drive_path" "$size"
    fi
}

mgr_ensure_device_disk() {
    local drive_path="$1"
    local format="$2"
    local template_source="${3:-}"
    local template_mode="${4:-full}"
    local template_format="${5:-qcow2}"

    if [ ! -b "$drive_path" ]; then
        echo "ERROR: Target block device $drive_path not found!" >&2
        exit 1
    fi

    if [ -n "$template_source" ]; then
        template_init_device "$drive_path" "$template_source" "$template_mode" "$template_format"
    fi
}

mgr_ensure_disk() {
    local type="$1"                # file | device
    local path="$2"                # disk_path 
    local format="$3"              # qcow2 | raw
    local size="${4:-}"            # disk_size
    local tmpl_source="${5:-}"     # URL or Path 
    local tmpl_mode="${6:-linked}" # linked | full
    local tmpl_format="${7:-}"     # qcow2 | raw

    if [ -n "$tmpl_source" ] && [ -z "$tmpl_format" ]; then
        if [[ "$tmpl_source" == *.raw ]] || [[ "$tmpl_source" == *.img ]]; then
            tmpl_format="raw"
        else
            tmpl_format="qcow2"
        fi
    fi

    if [ "$type" = "file" ]; then
        mgr_ensure_file_disk "$path" "$format" "$size" "$tmpl_source" "$tmpl_mode" "$tmpl_format"
    elif [ "$type" = "device" ]; then
        mgr_ensure_device_disk "$path" "$format" "$tmpl_source" "$tmpl_mode" "$tmpl_format"
    else
        echo "ERROR: Unknown drive type '$type'!" >&2
        exit 1
    fi
}
