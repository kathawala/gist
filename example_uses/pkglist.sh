#!/bin/bash
# Be sure to set USER before using or your gist will be
# private and anonymous and useless.

set -o errexit
trap "rm /tmp/pkglist &> /dev/null" EXIT

# Example: if user is named sonic then line should read USER="-usonic" 
# (-u must prepend username)
USER=""

cd /tmp
pacman -Qqe | grep -v "$(pacman -Qqm)" > pkglist
echo "===========================================" >> pkglist
pacman -Qqm >> pkglist

gist ${USER} -p -d "Official pkgs (aur pkgs appended at end)" pkglist
