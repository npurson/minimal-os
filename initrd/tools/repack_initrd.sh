# Repack an initrd image from
# the CURRENT DIRECTORY.

# find . -path ./tools -prune -o -print | cpio -o -H newc | gzip > /boot/initrd.img-5.11.0-25-modified
find . -path ./tools -prune -o -print | cpio -o -H newc | xz -9 --check=crc32 > /boot/initrd.img-5.11.0-25-modified
