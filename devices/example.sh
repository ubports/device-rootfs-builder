#!/bin/bash

# Add the device to the registry
add_device "example"

# NOTE: all these functions and arguments MUST start with the device name
# you set with add_device, like [DEVICE]_args/help/build
# Example if you set add_device "pine64"
# The argumetns will be pine64_args and pine64_help
# and the function will be pine64_build()

# Set the argument types, this is used for checking the arguments
# string: just checks for a string
# file: check if a file exists
example_args="string file file"

# Set the help for arguments, this gets return to the user
# This should just include the arguments!
example_help="[Output file name] [Rootfs tarball] [Bootloader]"

# This is the main function that gets executed when all the args are verifed
example_build() {
    local IMAGE_NAME="$1"
    local ROOTFS_TARBALL="$2"
    local BOOTLOADER="$3"

    create_and_attatch_empty_image ${IMAGE_NAME}
    create_vfat p1
    create_swap p2
    create_ext4 p3
    mount_extract_umount_rootfs p3 ${ROOTFS_TARBALL}
    flash_bootloader ${BOOTLOADER}
    deattatch_image
}
