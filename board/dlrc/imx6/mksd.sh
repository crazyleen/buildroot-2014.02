#!/bin/bash

help() 
{
	bn=`basename $0`
	cat << EOF
usage:
	$bn device_node
	$bn device_node update
EOF
}

format_linux_partition()
{
    echo "formating android images"
    mkfs.msdos -F 32 ${node}1 -n imx6
    mkfs.ext3 ${node}2 -Lrootfs
    mkfs.ext3 ${node}3 -Loverlay
    mkfs.msdos -F 32 ${node}4 -n SD
    sync
}

flash_linux_image()
{
    echo "flashing images..."    
    test -d /media/imx6 && {
        test -d /media/imx6/boot/ || mkdir /media/imx6/boot
        cp uImage /media/imx6/boot/ && echo 'flash uImage'
    }

    test -d /media/rootfs && {
        rm -rf /media/rootfs/*
        tar -xf rootfs.tar.bz2 -C /media/rootfs  && echo 'flash rootfs'
        chmod 775 /media/rootfs /media/rootfs/*
    }

    dd if=u-boot.imx of=${node} bs=1k seek=1 && echo 'flash u-boot'
    dd if=uImage of=${node} bs=1M seek=1 
    sync
}

node=$1

# check the if root?
userid=`id -u`
if [ $userid -ne "0" ]; then
	echo "you're not root?"
	exit
fi

if [ ! -e ${node} ]; then
	help
	exit
fi

if [ ${node} = "/dev/sda" ]; then
	help
	exit
fi

test "$2" = "update" && {
	flash_linux_image 
	exit 0
}


umount /media/* 2>/dev/null

# partition size in MB
BOOTLOAD_RESERVE=8
BOOT_ROM_SIZE=64
ROOTFS_SIZE=1024
OVERLAY_SIZE=1024

# call sfdisk to create partition table
# get total card size
total_size=`sfdisk -s ${node}`
total_size=`expr ${total_size} / 1024`
boot_rom_sizeb=`expr ${BOOT_ROM_SIZE} + ${BOOTLOAD_RESERVE}`
SD_SIZE=`expr ${total_size} - ${boot_rom_sizeb} - ${ROOTFS_SIZE} - ${OVERLAY_SIZE}`


cat << EOF
BOOT	: ${boot_rom_sizeb}MB
ROOTFS	: ${ROOTFS_SIZE}MB
OVERLEY	: ${OVERLAY_SIZE}MB
SD		: ${SD_SIZE}MB
EOF


# destroy the partition table
dd if=/dev/zero of=${node} bs=1M count=10
sync 

sfdisk --force -uM ${node} << EOF
,${boot_rom_sizeb},c
,${ROOTFS_SIZE},83
,${OVERLAY_SIZE},83
,${SD_SIZE},c
EOF

# adjust the partition reserve for bootloader.
# if you don't put the uboot on same device, you can remove the BOOTLOADER_ERSERVE
# to have 8M space.
# the minimal sylinder for some card is 4M, maybe some was 8M
# just 8M for some big eMMC 's sylinder
sfdisk --force -uM ${node} -N1 << EOF
${BOOTLOAD_RESERVE},${BOOT_ROM_SIZE},c
EOF

sync

format_linux_partition
echo 'format partitions done'
echo 'replug SD card to auto mount partitions, press any key to continue'
read read_TEMP
flash_linux_image
