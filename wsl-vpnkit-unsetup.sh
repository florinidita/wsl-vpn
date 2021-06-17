#!/usr/bin/env bash

set -eu

source common.env

# Arg Parse
additional_wsl=0
while (( $# )); do
  case "${1}" in
    --additional-wsl)
      additional_wsl=1
      ;;
    *)
      echo "Usage: $0 [--additional-wsl]" >&2
      exit 2
      ;;
  esac
  shift 1
done

if [ ${EUID:-$(id -u)} -ne 0 ]; then
  echo "You need to run this as roto"
  exit 1
fi

if [ "${additional_wsl}" = "0" ]; then
  service wsl-vpnkit stop || :

  rm_if /usr/local/bin/wsl-vpnkit-start.sh
  rm_if /etc/init.d/wsl-vpnkit
  rm_if /etc/sudoers.d/wsl-vpnkit
  rm_if /usr/local/sbin/vpnkit-tap-vsockd

  rm_if /mnt/c/bin/npiperelay.exe "${SYSTEM_ROOT}/system32/taskkill.exe" /im npiperelay.exe
  rm_if /mnt/c/bin/wsl-vpnkit.exe "${SYSTEM_ROOT}/system32/taskkill.exe" /im wsl-vpnkit.exe
  rmdir /mnt/c/bin || :

  # sed_file '/service wsl-vpnkit start/d' /etc/profile
  rm_if /etc/profile.d/wsl-vpnkit.sh
  sed_file '/service wsl-vpnkit start/d' /etc/zsh/zprofile
fi

if [ -e /etc/.wsl.conf.orig ]; then
  if ! grep -q '^generateResolvConf = false' /etc/.wsl.conf.orig; then
    sed_file '/^generateResolvConf = false.*/d' /etc/wsl.conf
    # On the next restart of wsl, the symlink will be recreated
    rm /etc/resolv.conf
  fi
  rm /etc/.wsl.conf.orig
fi

echo "Removed! Please restart this WSL to fully restore /etc/resolv.conf"
