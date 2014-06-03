# IMX6 buildroot usage

### 

*target*: board/dlrc/imx6/

*u-boot*: dl/u-boot-2013.10.tar.bz2

*linux*:  dl/linux-3.0.35-gpu-4.1.0-wand.tar.bz2

## compile

### using tar file

	tar xf buildroot-2014.02-imx6.tar.bz2 -C /opt/dlrc/

	#copy tar files to dl/

### using git

	cd /opt/dlrc

	git clone https://github.com/crazyleen/buildroot-2014.02.git

	mv buildroot-2014.02 buildroot-2014.02-imx6
	
	cd buildroot-2014.02-imx6

	git checkout imx6

	#copy tar files to dl/

### Compile minimal file system

	make dlrc_imx6_minimal_defconfig

	make


## toolchain usage

Toolchain bin: /opt/dlrc/buildroot-2014.02-imx6/output/host/usr/bin

Target: arm-buildroot-linux-uclibcgnueabi

set path: source /opt/dlrc/buildroot-2014.02-imx6/envsetup.sh

## make bootable sd card

### creat and format partitions, flash images

open a terminal at *output/images*

	sudo sh mksd.sh /dev/sdb

### update images to sd without creating partitions

	sudo sh mksd.sh /dev/sdb update









