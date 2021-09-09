# Customizing Initrd

Please refer to [history](./history.sh) for explicit steps.

## Initrd

1. Provides a temporary root fs
2. Loads essential drivers for accessing the real rootfs
3. Mounts root fs
4. Switch to the real rootfs as root

Probe devices (udevd) -> Fsck -> Remount
-> Services -> Login prompt (getty + /bin/login)

### udevd

* Depends: sysfs, Mounts `/sys`
* Rules: `/lib/udev`
* Configs: `/etc/udev`
* Create device nodes under `/dev`

### login prompt

* PAM:
  * Configs: `/etc/pam.d`
  * Depends: `/lib/security`

## Usage of Scripts

Add commands **with the dependencies required** to **the current directory as root**.

    $ bash tools/addcmd.sh COMMAND...

Add kernel modules **with dependencies** to **the current directory as root**. (Used in v0.55)

    $ bash tools/addmod.sh MODULE...

Repack an initrd image from the current directory.

    $ bash tools/repack_initrd.sh

Show the information about modules in the Linux Kernel for a better viewing, compared to `lsmod` and `modinfo`.

    $ bash tools/lsmodinfo.sh

## 0 GRUB Config

* Suppress the default hidden behavior in `/etc/default/grub`.
* Add GRUB Menu entry for customized initrd in `/boot/grub/grub.cfg`.

## 0.5 Acquiring Shell

Powerful commands: `ldd`, `file`, `man`

    $ file /boot/initrd.img-5.11.0-25-generic
    /boot/initrd.img-5.11.0-25-generic: ASCII cpio archive (SVR4 with no CRC)

Extract content from an initramfs image

    $ unmkinitramfs

Repack initramfs image

    $ find . -path ./tools -prune -o -print | cpio -o -H newc | gzip > /boot/initrd.img-5.11.0-25-modified

**Give `init` the execute permission**, otherwise no working init -> kernel panic -> CPU disabled

    $ chmod 755 init

## 0.55 Mount the Original System

### `init`

```bash
#!/bin/bash
export PATH=/usr/sbin:/usr/bin:/bin

insmod /lib/modules/5.11.0-25-generic/kernel/drivers/message/fusion/mptbase.ko
insmod /lib/modules/5.11.0-25-generic/kernel/drivers/message/fusion/mptscsih.ko
insmod /lib/modules/5.11.0-25-generic/kernel/drivers/scsi/scsi_transport_spi.ko
insmod /lib/modules/5.11.0-25-generic/kernel/drivers/message/fusion/mptspi.ko

[ -d /dev ] || mkdir -m 0755 /dev
[ -d /root ] || mkdir -m 0700 /root
[ -d /sys ] || mkdir /sys
[ -d /proc ] || mkdir /proc
mount -t sysfs -o nodev,noexec,nosuid sysfs /sys
mount -t proc -o nodev,noexec,nosuid proc /proc

mknod /dev/sda3 b 8 3  # Look for major and minor numbers by `ls -l /dev/sdax`
mkfs -t ext4 /dev/sda3
mount /dev/sda3 /root

bash
```

## 0.6 udev - Device Management

`man udev udevadm systemd-udevd` for essential infomation.

Copy `rule.d` and `/lib/modules/5.11.0-25-generic/modules.*` from the unpacked initrd.

Trap: `/lib/systemd-udevd` is symbolic link to `/bin/udevadm`,
      make sure the target path is like `systemd-udevd -> ../../bin/udevadm`
      rather than `bin/udevadm`.

Trace the execution of `init` from the unpacked initrd and step into the running of `/scripts`,
to look for the commands launching `udevadm`.

### Copied from /scripts/init-top/udev

```bash
udevadm trigger --type=subsystems --action=add
udevadm trigger --type=devices --action=add
udevadm settle || true
```

Because udevadm executes asynchronously with the following `mount` command,
blocking is needed to wait until all current events are handled.

### init

```bash
#!/bin/bash
export PATH=/usr/sbin:/usr/bin:/sbin:/bin

[ -d /dev ] || mkdir -m 0755 /dev
[ -d /root ] || mkdir -m 0700 /root
[ -d /sys ] || mkdir /sys
[ -d /proc ] || mkdir /proc
[ -d /run ] || mkdir /run  # for udevd to create /run/udev
mount -t sysfs -o nodev,noexec,nosuid sysfs /sys
mount -t proc -o nodev,noexec,nosuid proc /proc

# Mount udev
mount -t devtmpfs -o $dev_exec,nosuid,mode=0755 udev /dev

log_level=info
SYSTEMD_LOG_LEVEL=$log_level /lib/systemd/systemd-udevd --daemon --resolve-names=never
udevadm trigger --type=subsystems --action=add
udevadm trigger --type=devices --action=add
udevadm settle || true

mount /dev/sda3 /root

bash
```

## 0.7 login

`chroot` to the directory of the custiomized initrd,
and look for missing files by `strace login`.

* /etc/shadow, /etc/passwd, /etc/pam.d, /lib/x86_64-linux-gnu/security
* _Login incorrect_: /etc/nsswitch.conf, /lib/x86_64-linux-gnu/libnss_*
* _Error in service module_: /etc/login.defs, /etc/security

## 0.9 /sbin/init - systemd

`systemd` must be executed with PID 1, thus `exec /sbin/init` should be
executed at the end of `init`, otherwise _kernel panic_.
No docs or manuals for the mechanisms of `systemd` are found,
PLEASE CONTRIBUTE IF YOU KNOW.

After multiple attempts, `agetty` is found to be the only command needed,
and `/lib/systemd` has to be copied.
Look for descriptions of systemd units by `man systemd.special`,
based on which to reduce the contents in `/lib/systemd`.

## 1.0 Network Connection

    $ bash tools/addcmd.sh ifconfig ping dhclient ip ssh sshd
    $ bash tools/addmod.sh e1000
    $ cp /etc/ssh etc -r
    $ sudo cp /etc/ssh/*_key etc/ssh/

### Configure Network

Execute the following commands when booting from the customized initrd.

Show the infomation of network interfaces

    $ ip link show

Set up the network adapter

    $ ip link set eth0 up

`/lib/firmware/xxx` the firmware of your network adapter may be needed if errors reported.

Configure the address of the network adapter

    $ ip addr add 192.168.0.99/24 dev eth0

Configure the default routing

    $ ip route add default via 192.168.0.1 dev eth0

### Start sshd

Edit `/etc/sshd_config`: `PermitRootLogin yes`.

Start `sshd` manually by execution with an absolute path
to listen for connections from clients.

    $ /sbin/init

## Configure Terminal

Look for terminfo descriptions

    $ infocmp
    # Reconstructed via infocmp from file: /lib/terminfo/x/xterm-256color
    xterm-256color | xterm with 256 colors

### /etc/profile

```bash
export PATH=/usr/sbin:/sbin:$PATH
export TERM=xterm-256color

# generated by ASCII Generator
echo -e \
"     \033[31m__  ___ \033[0m\033[32m_\033[0m         \033[33m_\033[0m  ____  _____\n" \
"   \033[31m/  |/  /\033[0m\033[32m(_)\033[0m\033[34m____\033[0m   \033[33m(_)\033[0m/ __ \/ ___/\n" \
"  \033[31m/ /|_/ /\033[0m\033[32m/ /\033[0m\033[34m/ __ \ \033[0m\033[33m/ /\033[0m/ / / /\__ \ \n" \
" \033[31m/ /  / /\033[0m\033[32m/ /\033[0m\033[34m/ / / /\033[0m\033[33m/ /\033[0m/ /_/ /___/ / \n" \
"\033[31m/_/  /_/\033[0m\033[32m/_/\033[0m\033[34m/_/ /_/\033[0m\033[33m/_/\033[0m \____//____/  \n"
```
