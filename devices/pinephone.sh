#!/bin/bash

add_device "pinephone"

pinephone_args="string file file file"
pinephone_help="[Output file name] [Rootfs tarball] [Kernel tarball] [Bootloader]"
pinephone_sudo=true

pinephone_build() {
    local IMAGE_NAME="$1"
    local ROOTFS_TARBALL="$2"
    local KERNEL_TARBALL="$3"
    local BOOTLOADER="$4"

    create_and_attatch_empty_image ${IMAGE_NAME}
    create_vfat p1
    create_swap p2
    create_ext4 p3
    mount_extract_umount_rootfs p3 ${ROOTFS_TARBALL}
    mount_extract_umount_rootfs p3 ${KERNEL_TARBALL}
    flash_bootloader ${BOOTLOADER}
    deattatch_image
}
