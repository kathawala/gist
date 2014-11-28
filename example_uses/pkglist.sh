#!/bin/bash
# Be sure to set USER before using or your gist will be
# private and anonymous and useless.

set -o errexit
trap "rm /tmp/pkglist &> /dev/null" EXIT

USER=""

cd /tmp
pacman -Qqe | grep -v "$(pacman -Qqm)" > pkglist
echo "===========================================" >> pkglist
pacman -Qqm >> pkglist

gist -u${USER} -p -d "Official pkgs (aur pkgs appended at end)" pkglist
