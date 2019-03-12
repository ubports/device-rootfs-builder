#!/bin/bash

create_empty_image() {
  IMAGE_NAME="$1"
  IMAGE_SIZE=6144M
  PART_POSITION=20480 # K
  FAT_SIZE=100 #M
  SWAP_SIZE=2048 # M

  fallocate -l $IMAGE_SIZE $IMAGE_NAME

  cat << EOF | fdisk $IMAGE_NAME
  o
  n
  p
  1
  $((PART_POSITION*2))
  +${FAT_SIZE}M
  t
  c
  n
  p
  2
  $((PART_POSITION*2+FAT_SIZE*1024*2))
  +${SWAP_SIZE}M
  t
  2
  82
  n
  p
  3
  $((PART_POSITION*2+FAT_SIZE*1024*2+SWAP_SIZE*1024*2))

  t
  3
  83
  a
  3
  w
EOF
}

# returns/sets: LOOP_DEVICE
attatch_image() {
  LOOP_DEVICE=$(losetup -f)
  losetup -P $LOOP_DEVICE $IMAGE_NAME
}

deattatch_image() {
  check_for_loop_device
  losetup -d $LOOP_DEVICE
  unset LOOP_DEVICE
}

check_for_loop_device() {
  if [ -z "$LOOP_DEVICE" ]; then
    panic "Loop device has not been attached"
  fi
}

create_vfat() {
  check_for_loop_device
  local DEV="$1"
  log_debug "Creating vfat filesystem on $DEV"
  mkfs.vfat ${LOOP_DEVICE}${DEV}
}

create_swap() {
  check_for_loop_device
  local DEV="$1"
  log_debug "Creating swap on $DEV"
  mkswap ${LOOP_DEVICE}${DEV}
}

create_ext4() {
  check_for_loop_device
  local DEV="$1"
  log_debug "Creating ext4 filesystem on $DEV"
  mkfs.ext4 ${LOOP_DEVICE}${DEV}
}

# return/sets: MOUNTED_ROOT
mount_root() {
  local DEV="$1"
  MOUNTED_ROOT=$(mktemp -d)
  mkdir -p $MOUNTED_ROOT
  log_debug "Mounting rootfs"
  mount ${LOOP_DEVICE}p3 $MOUNTED_ROOT
}

umount_root() {
  check_for_mounted_root
  log_debug "Unmounting rootfs"
  umount $MOUNTED_ROOT
  rm -rf $MOUNTED_ROOT
  unset MOUNTED_ROOT
}

check_for_mounted_root() {
  if [ -z "$MOUNTED_ROOT" ]; then
    panic "root has not been mounted"
  fi
}

extract_gz_to_root() {
  check_for_mounted_root
  local TARBALL="$1"
  log_debug "Extracting gz $1 to $MOUNTED_ROOT"
  tar -xzf "$TARBALL" -C "$DEST"
}

flash_bootloader() {
  local BOOTLOADER="$1"
  log_debug "Flashing bootloader"
  dd if=${BOOTLOADER} of=${LOOP_DEVICE} bs=8k seek=1
}

# convenient functions
create_and_attatch_empty_image() {
  create_empty_image $1
  attatch_image
}

mount_extract_umount_rootfs() {
  mount_root $1
  extract_gz_to_root $2
  umount_root
}
