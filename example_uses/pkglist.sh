#!/bin/bash
# For the best usage, set USER equal to your GitHub username rather than giving that info
# at the command line each time.

set -o errexit

USER=$1

FILENAME=`mktemp -t pkglist.XXXXXX`
trap "rm $FILENAME* 2>/dev/null" EXIT

pacman -Qqe | grep -v "$(pacman -Qqm)" > ${FILENAME}
echo "===========================================" >> ${FILENAME}
pacman -Qqm >> ${FILENAME}

gist -u${USER} -p -n "pkglist" -d "Official pkgs (aur pkgs appended at end)" ${FILENAME}
