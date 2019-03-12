#!/bin/bash

log_debug() {
  echo "DEBUG: $1"
}

panic() {
  echo "FATAL ERROR: $1"
  exit 1
}

user_error() {
  echo "$1"
  exit 1
}

add_device() {
  DEVICES="$DEVICES $1"
}

print_device_help() {
  echo "Usage ./$SCRIPT_NAME $1 $2"
}
