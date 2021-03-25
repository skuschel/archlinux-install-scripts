#!/bin/bash

# Installs the arch bootloader

# make sure to run this scirpt AFTER arch-chrooting into the new system.

# Stephan Kuschel, 2021

HOSTNAME=Arch
ROOTPWD=root  # root password default


# exit when any commant fails
set -e
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT


echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen

locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo $HOSTNAME > /etc/hostname

echo "root:${ROOTPWD}" | chpasswd


# mkinitcpio

pacman -S lvm2
sed -i 's/^HOOKS.*/HOOKS="base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck"/' /etc/mkinitcpio.conf
mkinitcpio -p linux


# bootloader
pacman -S efibootmgr
bootctl install
# Work-in-progress



























