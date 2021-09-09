# GRUB Installation on USB Disk

Install the required packages

    $ sudo su
    # apt update && apt upgrade
    # apt install git bison libopts25 libselinux1-dev m4 help2man libopts25-dev flex libfont-freetype-perl automake make autotools-dev autopoint libfreetype6-dev texinfo python autogen autoconf libtool libfuse3-3 unifont gettext binutils pkg-config liblzma5 libdevmapper-dev

Bootstrap GRUB

    # git clone git://git.savannah.gnu.org/grub.git
    # cd grub
    # ./bootstrap

Compile GRUB for 64 bit UEFI

    # mkdir efi64
    # cd efi64
    # ../configure --target=x86_64 --with-platform=efi && make

Mount your USB disk

    # fdisk -l
    # mkdir /mnt/usb
    # mount /dev/sdb1 /mnt/usb

Install GRUB

    # cd ../efi64/grub-core
    # grub-install -d $PWD --force --removable --no-floppy --target=x86_64-efi --boot-directory=/mnt/usb/boot --efi-directory=/mnt/usb
