#!/bin/bash

echo -e "\nInstall desktop packages ..."
[ $EUID -ne 0 ] \
  && echo 'skipped, requires root' \
  && exit 1

apt -q=2 install \
    openjdk-11-jdk openjdk-11-source openjdk-11-doc visualvm \
    gnome-system-tools gnome-system-monitor gnome-disk-utility \
    grub-customizer glances hfsprogs gvfs-backends gvfs-fuse \
    gufw gparted baobab chromium enpass geany vlc gimp clipit

exit 0
