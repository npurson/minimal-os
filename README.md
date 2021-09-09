# Minimal OS

Labs for *Linux Introduction* course. Based on Ubuntu 21.04 & Linux Kernel 5.14.

* Customize the latest Linux kernel and initial ramdisk file system
* Require kernel < 4 MB & initrd.img < 24 MB
* Features:
  * Boot by loading kernel & img from USB disk
  * Multi-user login support (console & SSH)
  * SSH remote access
  * Able to mount USB disk
  * Able to access the Windows partition on host (ntfs-3gfs support)

## Steps

1. [Customizing Initrd](initrd/README.md)
2. [Triming & Building the Kernel](kernel/README.md)
3. [GRUB Installation on USB Disk](grub_install/README.md)
