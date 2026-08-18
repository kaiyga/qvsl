# QVSL - Qemu Virtual machine start with Language

QVSL is a lightweight proof-of-concept that brings a declarative approach to QEMU management using Docker, Go-templates, and pure Bash arrays.

Think of `vm.yaml` as a `values.yaml` in Helm, but specifically designed for QEMU virtual machines.

Instead of dealing with massive, unreadable `qemu-system-*` bash strings or heavy virtualization management tools, QVSL uses:
- **`vm.yaml`**: Declarative configuration of your VM (CPU, RAM, drives, cloud-init, networking).
- **`qemu-run.sh.tmpl`**: A Go-template that compiles your YAML into clean, bulletproof Bash execution logic and argument arrays.
- **Docker Container**: A single, reproducible runner containing QEMU, Cloud-Init ISO generators, and optional noVNC web console.

# Quick start

Download Alpine Cloud-Template

```
curl -L https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/cloud/generic_alpine-3.22.5-x86_64-bios-cloudinit-r0.qcow2 -o ./vm-data/template.qcow2
```

Insert your user-data in `vm.yaml` - `cloud_init.config` or use [`cloud-init/user-data`](./cloud-init/user-data)

And lets goooo!
```
docker compose up
```

You can see VNC console on 
```
http://localhost:6080/vnc.html
```
Or connect via SSH
```
ssh -p 2222 root@localhost
```

# Files

- vm.yaml: Manifest file with VM declaration (works with any Linux distribution).
- qemu-run.sh.tmpl: Go-template that acts as the pre-init script and QEMU CLI builder.
- docker-compose.yml: Runner container environment setup (KVM passthrough, storage mounts).

# Featurest 

- Storage Engines: Support for QCOW2 files and raw LVM block devices.
- Smart Provisioning: Auto-creation of Linked (CoW) or Full copy disks from base templates.
- Auto-Resize: Automatic virtual disk expansion using qemu-img resize prior to boot.
- Cloud-Init Engine: Dynamic cidata seed ISO generation on the fly.


# Thanks
- (bluebrown/go-template-cli)[https://github.com/bluebrown/go-template-cli]. Its the great thing for automotisation
