#!/bin/bash

SRC=$(dirname "$0")
SCRIPT_NAME=$(basename "$0")

### Source import
# shellcheck source=src/common.sh
source $SRC/src/common.sh
# shellcheck source=src/image.sh
source $SRC/src/image.sh

### Devices import
# shellcheck source=devices/pinephone.sh
source $SRC/devices/pinephone.sh

show_help() {
  echo "Build device images, supported devices and arguments:"
  for dev in $DEVICES; do
    local arg="${dev}_help"
    echo "./$SCRIPT_NAME $dev ${!arg}"
  done
}

show_device_help() {
  local arg="$1_help"
  print_device_help $1 "${!arg}"
}

list_devices() {
  for dev in $DEVICES; do
    echo "$dev"
  done
}

check_args() {
  local args="$1_args"
  num=1
  for arg in ${!args}; do
    local thearg="${ARGS[${num}]}"
    if [ -z "$thearg" ]; then
      echo "Missing arguments!"
      show_device_help $1
      exit 0
    fi
    if [ "$thearg" == "help" ]; then
      show_device_help $1
      exit 0
    fi
    case "$arg" in
      "file")
        if [ ! -f $thearg ]; then
          user_error "Could not find file $thearg"
        fi
        ;;
      "string")
        if [ -z "$thearg" ]; then
          user_error "Missing argument"
        fi
        ;;
    esac
    num=$((num+1))
  done
}

call_device() {
  local sudo="$1_sudo"
  if [ "${!sudo}" == true ]; then
    if [[ $(id -u) -ne 0 ]]; then
      echo "$1 needs sudo, please run as root"
      exit 1
     fi
  fi
  check_args "$1"
  local func="$1_build"
  # shellcheck disable=SC2068
  ${func} ${ARGS[@]:1}
}

ARGS=("$@")

case "$1" in
  "list")
    list_devices
    ;;
  "pinephone")
    call_device "pinephone"
    ;;
  *)
    show_help
    ;;
esac
