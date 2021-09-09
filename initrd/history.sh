mkdir -p usr/bin usr/sbin usr/lib usr/lib64
ln -s usr/bin bin
ln -s usr/sbin sbin
ln -s usr/lib lib
ln -s usr/lib64 lib64
touch init
chmod 755 init

export INITRD=/path/to/the/unpacked/original/initrd
bash tools/addcmd.sh bash ls pwd mkdir cp file cat mount umount df fdisk udevadm lsmod login
bash tools/addmod.sh mptspi
mkdir lib/systemd
ln -s ../../bin/udevadm lib/systemd/systemd-udevd
mkdir lib/udev/
cp $INITRD/lib/udev/rules.d lib/udev/ -r
cp $INITRD/lib/modules/5.11.0-25-generic/modules.* lib/modules/5.11.0-25-generic/

mkdir etc
sudo cp /etc/shadow etc/  # set root passwd before copy
cp /etc/passwd etc/  # replace the shell with bash if it isn't
cp /etc/pam.d etc/ -r
cp /etc/nsswitch.conf etc/
cp /etc/login.defs etc/
cp /etc/security etc/ -r
bash tools/addcmd.sh /lib/x86_64-linux-gnu/security/* /lib/x86_64-linux-gnu/libnss_*

touch etc/profile  # export PATH & TERM
bash tools/addcmd.sh /lib/systemd/systemd systemctl agetty
ln -s /lib/systemd/systemd sbin/init
cp -r /lib/systemd lib/  # TODO remove gdm, gnome, gvfs, xdg, brltty, etc.

bash tools/addcmd.sh ifconfig ping dhclient ip ssh sshd
bash tools/addmod.sh e1000
cp /etc/ssh etc -r  # edit `/etc/sshd_config`: `PermitRootLogin yes`
sudo cp /etc/ssh/*_key etc/ssh/

# configure terminal
mkdir -p lib/terminfo/x/
cp /lib/terminfo/x/xterm-256color lib/terminfo/x/xterm-256color

cp /lib/firmware/rtl_nic lib/firmware -r  # firmware of your network adapter
