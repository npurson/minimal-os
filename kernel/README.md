# Triming & Building the Kernel

RTFM: **R**ead **T**he **F**ucking **M**anual!

    $ make menuconfig
    ...
    $ make -j16

Requirements of `systemd` can be found in the <https://github.com/systemd/systemd/blob/main/README>.

Type `/` in the menuconfig to search, and type `1` to jump to its configuration.

## Traps

* Support for laptop keyboard is `Device Drivers` → `HID support` → `Generic HID driver`
  rather than
* `Device Drivers` → `Frame buffer Devices` is essential for the display of console.

## Referrence

* [lpyOS](https://gitee.com/eiclpy/lpyos)
