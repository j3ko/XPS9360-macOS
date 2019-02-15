# macOS on Dell XPS 9360

This repository contains a sample configuration to run macOS (Currently Mojave Sierra `10.14.3`) on a Dell XPS 9360

## Used Hardware Configuration

- Dell XPS 9360
  - Intel i7-8550U
  - 16GB RAM
  - Sharp `SHP144` `LQ133Z1` QHD+ (3200x1800) Touchscreen display
  - [Western Digital Black 512GB SSD](http://a.co/8JOsXFG) (WDS512G1X0C-00ENX0) on latest firmware
    - Formatted for APFS with 4K sectors, using [nvme-cli](https://github.com/linux-nvme/nvme-cli) using this [guide](https://www.tonymacx86.com/threads/guide-sierra-on-hp-spectre-x360-native-kaby-lake-support.228302/)
  - Dell DW1560 Wireless (eBay)
    - Wi-Fi device ID [`14e4:43b1`], shows as Apple Airport Extreme due to `FakePCIID_Broadcom_WiFi.kext`
    - Bluetooth device ID [`0a5c:216f`], chipset `20702A3` with firmware `v14 c5882` using `BrcmPatchRAM2.kext`
  - Sonix Technology Webcam, device ID [`0c45:670c`], works out of the box
  - Validity Inc. Finger print scanner, device ID [`138a:0091`], [linux open-source project](https://github.com/hmaarrfk/Validity91)
  - Disabled devices
    - Touchscreen (though it works out of the box if enabled)
    - SD card reader, [macOS open-source project](https://github.com/sinetek/Sinetek-rtsx)

- Firmware Revisions
  - BIOS version `2.9.0`
  - Thunderbolt Controller firmware version `NVM 26`

- External Devices
  - [Caldigit USB-C Dock](http://a.co/8I1agKD)
    - Supports USB-C PD (Power Delivery), Ethernet, 3x USB-3, USB-C, HDMI & DisplayPort connections
  - [Dodocool 7-in-1 USB-C Hub](http://a.co/eGmk4K9)
    - USB-C PD (Power Delivery), Ethernet, 1x USB-3 & HDMI connections
  - [Benfei USB-C Adapter](http://a.co/1Lcm6Ot)
    - USB-C PD (Power Delivery), Ethernet, 1x USB-3 & HDMI connections

- Monitors
  - [HP E273q 27" QHD TFT](http://www8.hp.com/us/en/products/monitors/product-detail.html?oid=18164507)
  - [HP E272 27" QHD TFT](http://www8.hp.com/h20195/v2/GetDocument.aspx?docname=c04819807)
  - [HP E222 21.5" HD TFT](http://www8.hp.com/ca/en/products/monitors/product-detail.html?oid=8402841)

## Preparation

This repository has been tested against Dell XP 9360 bios version `2.8.1` with Thunderbolt firmware `NVM 26.1`. For best results ensure this is the bios version of the target machine.

## UEFI Variables

In order to run macOS successfully a number of EFI BIOS variables need to be modified. The included Clover bootloader contains an updated `DVMT.efi`, which includes a `setup_var` command to help do just that.

`DVMT.efi` can be launched from Clover directly by renaming it to `Shell64U.efi` in the `tools` folder.

The following variables need to be updated:

| Variable              | Offset | Default value  | Desired value   | Comment                                                    |
|-----------------------|--------|----------------|-----------------|------------------------------------------------------------|
| CFG Lock              | 0x4de  | 0x01 (Enabled) | 0x00 (Disabled) | Disable CFG Lock to prevent MSR 0x02 errors on boot        |
| DVMT Pre-allocation   | 0x785  | 0x01 (32M)     | 0x06 (192M)     | Increase DVMT pre-allocated size to 192M for QHD+ displays |
| DVMT Total Gfx Memory | 0x786  | 0x01 (128M)    | 0x03 (MAX)      | Increase total gfx memory limit to maximum                 |

## Clover Configuration

All Clover hotpatches are included in source DSL format in the DSDT folder.
If required the script `--compile-dsdt` option can be used to compile any changes to the DSL files into `./CLOVER/ACPI/patched`.

## AppleHDA

In order to support the Realtek ALC256 (ALC3246) codec of the Dell XPS 9360, AppleALC is included with layout-id `56`.

Alternatively, a custom AppleHDA injector can be used.
The script option `--patch-hda` option generates an AppleHDA_ALC256.kext injector and installs it in `/Library/Extensions` for this purpose, in this case the layout-id is `1`.

## Display Profiles

Display profiles for the Sharp LQ133Z1 display (Dell XPS 9360 QHD+) are included in the displays folder.

Profiles can be installed by copying them into `/Users/<username>/Library/ColorSync/Profiles` folder, additionally the macOS built-in `ColorSync` utility can be used to inspect the profiles.

Profiles are configured on a per display basis in the `System Preferences` -> `Display` preferences menu.

## CPU Profile

In order for macOS to effectively manage the power profile of the i7-8550U processor in the Dell XPS 9630 model used here, it is necessary to include a powermanagement profile for `X86PlatformPlugin`.

A pre-built `CPUFriend.kext` and `CPUDataProvider.kext` is included in the `kext` folder for the i7-8550U.

Instructions on how to build a power mangaement profile for any other CPU types can be found here:

https://github.com/PMheart/CPUFriend/blob/master/Instructions.md

## Undervolting

**Warning [undervolting](https://en.wikipedia.org/wiki/Dynamic_voltage_scaling) may render your XPS 9360 unusable**

Essentially it allows your processor to run on a lower voltage than its specifications, reducing the core temperature.

This allows longer battery life and longer turbo boost.

Credits for this go to jkbuha at tonymacx86.

The undervolt settings I use are configured in UEFI, with the following settings:

- Overclock, CFG, WDT & XTU enable  
  `0x4DE` -> `00`  
  `0x64D` -> `01`  
  `0x64E` -> `01`

- Undervolt values:  
  `0x653` -> `0x64` (CPU: -100 mV)  
  `0x655` -> `01`   (Negative voltage for `0x653`)  
  `0x85A` -> `0x1E` (GPU: -30 mV)  
  `0x85C` -> `01`   (Negative voltage for `0x85A`)

Remember, these values work for my specific machine, but might cause any other laptop to fail to boot!

## HiDPI
For a fhd display, use [one-key-hidpi](https://github.com/xzhih/one-key-hidpi)

## What you need

1. USB drive x2
1. Another computer running macOS
1. [Ubuntu 18.04+ ISO](https://www.ubuntu.com/download/desktop/thank-you?country=JP&version=18.04.1&architecture=amd64)
1. [Clover EFI bootloader v2.4 r4862](https://sourceforge.net/projects/cloverefiboot/)
1. [Clover Configurator v.5.3.0.0](https://mackie100projects.altervista.org/download-clover-configurator/)

## Walkthrough

1. Create Ubuntu live usb drive (UEFI bootable)

    1. Open the Terminal Application.
    1. Type command to convert the .iso file to .img using the convert option.
        ```
        hdiutil convert -format UDRW -o /path/to/target.img /path/to/ubuntu.iso
        ```
    1. Insert your flash media.
    1. Type command to determine the device node assigned to your flash media (e.g. /dev/disk2).
        ```
        diskutil list
        ```
    1. Type command to unmount the flash (replace N with the disk number from the last command; in the previous example, N would be 2).
        ```
        diskutil unmountDisk /dev/diskN
        ```
    1. Type DD command (replace /path/to/downloaded.img with the path where the image file is located; for example, ./ubuntu.img). Prepend the device path with "r" for the [raw path which is much faster](https://superuser.com/questions/631592/why-is-dev-rdisk-about-20-times-faster-than-dev-disk-in-mac-os-x) than without the "r".
        ```
        sudo dd if=/path/to/downloaded.img of=/dev/rdiskN bs=1m
        ```
    *Note: your file might also be called `downloaded.img.dmg`. That's okay.*

1. Create bootable Mojave usb drive

    1. Format the USB drive
        1. Format: APFS
        1. Scheme: GUID
    1. Install Mojave on the USB drive
        ```
        sudo /Applications/Install\ macOS\ Mojave.app/Contents/Resources/createinstallmedia –volume /Volumes/[USB NAME HERE] –nointeraction
        ```
    1. Install Clover EFI bootloader
    1. Under `Change Install Location...` select the USB drive
    1. Under `Customize` make sure the following are checked:
        1. Clover for UEFI booting only
        1. Install Clover in the ESP 
        1. In themes, select a theme
    1. After Clover installs, open Clover configurator
    1. Under `Mount EFI`, mount the USB drive partition
    1. Replace the `/EFI/Clover` folder with the Clover folder in this repo
    1. Delete all folders in `/EFI/Clover/ktexts` except "Other"
    1. From the repo `/ktexts` copy everything except the folders and text files into `/EFI/Clover/ktexts`
    1. Under `/tools` delete the current `Shell64U.efi` file and rename `DVMT.efi` to `Shell64U.efi`
    1. Open `/EFI/Clover/config.plist` in Clover configurator and under `Boot -> Custom Flags`, add `alcid=56`

1. Preparing laptop
    1. Updating BIOS
        - Sata: AHCI
        - Enable SMART Reporting
        - Disable thunderbolt boot and pre-boot support
        - USB security level: disabled
        - Enable USB powershare
        - Enable Unobtrusive mode
        - Disable SD card reader (saves 0.5W of power)
        - TPM Off
        - Deactivate Computrace
        - Enable CPU XD
        - Disable Secure Boot
        - Disable Intel SGX
        - Enable Multi Core Support
        - Enable Speedstep
        - Enable C-States
        - Enable TurboBoost
        - Enable HyperThread
        - Disable Wake on USB-C Dell Dock
        - Battery charge profile: Standard
        - Numlock Enable
        - FN-lock mode: Disable/Standard
        - Fastboot: minimal
        - BIOS POST Time: 0s
        - Enable VT
        - Disable VT-D
        - Wireless switch OFF for Wifi and BT
        - Enable Wireless Wifi and BT
        - Allow BIOS Downgrade
        - Allow BIOS Recovery from HD, disable Auto-recovery
        - Auto-OS recovery threshold: OFF
        - SupportAssist OS Recovery: OFF

    1. Preparing HD
        1. Boot up in Ubuntu live 18.04
        1. Under `Software & Updates` enable `Community-maintained free and open-sourced software (universal)`
        1. Run the following:
            ```
            sudo apt update & sudo apt install smartmontools nvme-cli
            sudo smartctl -a /dev/nvme0n1
            sudo nvme format -l 1 /dev/nvme0n1
            ```
  
1. Installing
    1. Boot from Clover USB
    1. In the shell, run the following:
        ```
        setup_var 0x4de 0x00
        setup_var 0x785 0x06
        setup_var 0x786 0x03
        ```
    1. In options add -v to the boot options to enable verbose mode
    1. Boot up and install MacOS
    1. Reboot with the USB again and load using the newly installed MacOS
    1. This time install clover onto the NVME
    1. Copy over the clover folder from the USB
    1. Copy `/kexts/Library-Extensions` from the repo to `/Library/Extensions` on the NVME
    1. Run the following:
        ```
        sudo touch /Library/Extensions
        sudo chmod -R 755 /Library/Extensions
        sudo chown -R root:wheel /Library/Extensions
        sudo kextcache -i /
        ```

1. Post setup config
    1. Enable sleep:
        ```
        sudo pmset -a hibernatemode 0
        sudo pmset -a autopoweroff 0
        sudo pmset -a standby 0
        sudo rm /private/var/vm/sleepimage
        sudo touch /private/var/vm/sleepimage
        sudo chflags uchg /private/var/vm/sleepimage
        ```

    1. Install [ComboJack](https://github.com/hackintosh-stuff/ComboJack)
## Credits

- [Install macOS Mojave on XPS 13 (9360)](http://markperez.info/install-macos-mojave-on-xps-13-9360-step-by-step-hackintosh-guide/)
- [OS-X-Clover-Laptop-Config (Hot-patching)](https://github.com/RehabMan/OS-X-Clover-Laptop-Config)
- [Dell XPS 13 9360 Guide by bozma88](https://www.tonymacx86.com/threads/guide-dell-xps-13-9360-on-macos-sierra-10-12-x-lts-long-term-support-guide.213141/)
- [VoodooI2C on XPS 13 9630 by Vygr10565](https://www.tonymacx86.com/threads/guide-dell-xps-13-9360-on-macos-sierra-10-12-x-lts-long-term-support-guide.213141/page-202#post-1708487)
- [USB-C Hotplug through ExpressCard by dpassmor](https://www.tonymacx86.com/threads/usb-c-hotplug-questions.211313/)
- Kext authors mentioned in [kexts/kexts.txt](https://github.com/the-darkvoid/XPS9360-macOS/blob/master/kexts/kexts.txt)
