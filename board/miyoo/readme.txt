Intro
=====

This directory contains a buildroot configuration for building a Miyoo Bittboy.

https://github.com/TriForceX/MiyooCFW/blob/master/README.md#console-revisions-differences

How to build it
===============

Configure Buildroot
-------------------

  $ make miyoo_bittboy_defconfig

Build the rootfs
----------------

Note: you will need to have access to the network, since Buildroot
will download the packages' sources.

You may now build your rootfs with:

  $ make

(This may take a while, consider getting yourself a coffee ;-) )

How to write the SD card
========================

Once the build process is finished you will have an image called
"sdcard.img" in the output/images/ directory.

Copy the bootable "sdcard.img" onto an SD card with "dd":

  $ sudo dd if=output/images/sdcard.img of=/dev/sdX

Alternatively, you can use the Etcher graphical tool to burn the image
to the SD card safely and on any platform:

https://etcher.io/

Once the SD card is burned, insert it into your LicheePi Zero board,
and power it up. Your new system should come up now and start a
console on the UART0 serial port.
