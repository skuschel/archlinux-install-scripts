#!/bin/bash

# Installs Arch such that you can arch-chroot into the new system. It is still
# not bootable. Bootloader and lvm2 support remains to be installed.

# update the device. ITS CONTENTS WILL BE DESTROYED

# Stephan Kuschel, 2021

DEVICE=/dev/sdb

LUKSPASS='luks'
LVMNAME='BLACK'  # prefix, must be different from current machine

# exit when any commant fails
set -e
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# check a few things

dialog --yesno "All data on Device $DEVICE will be destroyed! Proceed?" 0 0 || exit


if [[ $(mount | grep -c $DEVICE) -ge 1 ]]
  then echo "Device $DEVICE is in use. Exiting."
  exit
fi

if [ $(id -u) -ne 0 ]
  then echo "must run as root."
  exit
fi



# partition 

sgdisk --zap-all $DEVICE
# boot partition
sgdisk -n=1:0:500M -t 1:ef00 $DEVICE
# data partition
sgdisk -n=2:0:0 $DEVICE

# Encryption

printf "%s" "$LUKSPASS" | cryptsetup luksFormat ${DEVICE}2 -
printf "%s" "$LUKSPASS" | cryptsetup luksOpen ${DEVICE}2 ${LVMNAME}crypt -

vgcreate ${LVMNAME}vg /dev/mapper/${LVMNAME}crypt

lvcreate -L 16G ${LVMNAME}vg -n swapvol
lvcreate -L 150G ${LVMNAME}vg -n rootvol
lvcreate -l +100%FREE ${LVMNAME}vg -n homevol

# format partitions

mkfs.fat -F32 ${DEVICE}1
mkswap /dev/mapper/${LVMNAME}vg-swapvol
mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 /dev/mapper/${LVMNAME}vg-rootvol
mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=0 /dev/mapper/${LVMNAME}vg-homevol


# mount
mount /dev/mapper/${LVMNAME}vg-rootvol /mnt
mkdir /mnt/home
mount /dev/mapper/${LVMNAME}vg-homevol /mnt/home
mkdir /mnt/boot
mount ${DEVICE}1 /mnt/boot


# install into /mnt
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab


echo "success! you can not arch-chroot into /mnt and install a bootloader"





































