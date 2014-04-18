#!/bin/sh

PDIR=/opt/dlrc/buildroot-2014.02-imx6
DATETIME=`date +%F-%H-%M`
sudo tar cjvf /opt/dlrc/buildroot-imx6-${DATETIME}.tar.bz2 ${PDIR}/output/host ${PDIR}/output/images
