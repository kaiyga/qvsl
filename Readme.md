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

# Files

Into `vm.yaml` you can put your configuration of VM. Its can work with all distros 

`vm.yaml` how `values.yaml` in helm for qemu and templated `qemu-run.sh.tmpl` script

`qemu-run.sh.tmpl` - is pre-init scripts and qemu args builder 

Serius its so simple and doent need more

