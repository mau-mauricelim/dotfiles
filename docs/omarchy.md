# Omarchy experience

## Installation of Omarchy

Installation of Omarchy 3.4 on a dual-drive mini PC was fairly easy and straightforward.
The first drive had Windows OS installed and a second drive that has no OS installed.
- Ensure Secure Boot (BIOS) and Fast Startup (Windows Power & Sleep setting) is disabled
- Download the ISO and flash it into a USB drive
- Boot into the USB drive
- Install into the selected drive
- Remove the USB drive once installed and reboot

### Issue: Booted into grub prompt instead of Linux/Windows bootloader (default)

Boot loader was not setup or installed correctly
- Type `exit` to boot into Windows
- From Windows, reboot into BIOS (link to cmd)
- Change boot option #1 to Limine (Omarchy uses this)
- Save and exit to reboot

### Issue: Booted into Limine bootloader but Windows entry is missing

- Select Omarchy > Linux to boot into it
- Open terminal (`Super + Enter`) inside Omarchy and run `sudo limine-scan`
- Choose Windows Boot Manager to add it to the boot menu
- Run `sudo nvim /boot/liminie.conf`
- Increase the timeout and move the Windows entry to the top (preference)

### Issue: Brave crashes on shutdown

- Disable the "Warn me before closing windows with multiple tabs" setting under Settings > System

### Issue: Caps Lock us remapped for hotkeys

- https://learn.omacom.io/2/the-omarchy-manual/88/troubleshooting#why-isn-39-t-caps-lock-working
- Removed xcompose key in `~/.config/hypr/input.conf` with `kb_options =`

## Installation of Windows 11 (Pro) on KVM

- (YouTube guide)[https://youtu.be/q8ZsO-h14Po?si=sxNKtEsatMqWqOPt]
- (Written guide)[https://sysguides.com/install-windows-11-on-kvm]

### Issue: Unable to skip the Windows install page for "Let's connect you to a network"

- Press `Shift + F10` to bring up the cmd prompt then enter `oobe\bypassnro`

### Issue: Unable to personalize Windows without activation

- (Activation Methods)[https://massgrave.dev/#activation-methods]
- Open PowerShell and run `irm https://get.activated.win | iex`

### Issue: Remove Windows bloat

- (Chris Titus Tech's Windows Utility)[https://github.com/ChrisTitusTech/winutil]

### Issue: Logitech G304 mouse side buttons not working inside VM

- Install (Input Remapper)[https://github.com/sezanzeb/input-remapper/tree/main] and configure side buttons to send `Alt + Left/Right` keys

### Issue: Multiple monitors not working for VM

- Open `virt-manager`, select the VM and click `Open`
- Click on the blue information icon and `Add Hardware`
- Select `Video QXL`
- Ensure there are 2 (or as many monitors) `Video QXL` configured
- `virt-viewer` should now be able to toggle and select multiple monitors

## Installation of Citrix Workspace app for Windows

### Issue: Mouse tracking was poor

- From the Desktop Viewer toolbar, select Preferences > Connections > Enable `Use relative mouse`

> [!NOTE]
> - The relative mouse is a per-session feature
> - It does not persist after reconnecting to a disconnected session
> - Re-enable the feature every time you connect or reconnect to the session

## System information

<details>
   <summary>Click to expand</summary>

```sh
❯ date
Fri Mar 27 21:23:21 +08 2026

❯ uname -a
Linux omarchy 6.19.8-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 14 Mar 2026 01:07:43 +0000 x86_64 GNU/Linux

❯ inxi -FxzJ
System:
  Kernel: 6.19.8-arch1-1 arch: x86_64 bits: 64 compiler: gcc v: 15.2.1
  Desktop: Hyprland v: 0.54.2 Distro: Arch Linux
Machine:
  Type: Mini-pc System: Trigkey product: S5 v: N/A
    serial: <superuser required>
  Mobo: Trigkey model: S5 v: V1.0 serial: <superuser required>
    Firmware: UEFI vendor: American Megatrends LLC. v: 5800H507
    date: 12/11/2023
Battery:
  Device-1: hidpp_battery_0 model: Logitech G304 Lightspeed Wireless Gaming
    Mouse charge: 100% (should be ignored) status: discharging
CPU:
  Info: 8-core model: AMD Ryzen 7 5700U with Radeon Graphics bits: 64
    type: MT MCP arch: Zen 2 rev: 1 cache: L1: 512 KiB L2: 4 MiB L3: 8 MiB
  Speed (MHz): avg: 1115 min/max: 412/4374 boost: enabled cores: 1: 1115
    2: 1115 3: 1115 4: 1115 5: 1115 6: 1115 7: 1115 8: 1115 9: 1115 10: 1115
    11: 1115 12: 1115 13: 1115 14: 1115 15: 1115 16: 1115 bogomips: 57491
  Flags-basic: avx avx2 ht lm nx pae sse sse2 sse3 sse4_1 sse4_2 sse4a
    ssse3 svm
Graphics:
  Device-1: Advanced Micro Devices [AMD/ATI] Lucienne driver: amdgpu
    v: kernel arch: GCN-5 bus-ID: 04:00.0 temp: 50.0 C
  Display: wayland server: X.org v: 1.21.1.21 with: Xwayland v: 24.1.9
    compositor: Hyprland v: 0.54.2 driver: X: loaded: modesetting
    dri: radeonsi gpu: amdgpu resolution: no compositor data resolution:
    1: 1920x1080 2: 1920x1080
  API: EGL Message: EGL data requires eglinfo. Check --recommends.
  Info: Tools: x11: xprop
Audio:
  Device-1: Advanced Micro Devices [AMD/ATI] Renoir/Cezanne HDMI/DP Audio
    driver: snd_hda_intel v: kernel bus-ID: 04:00.1
  Device-2: Advanced Micro Devices [AMD] Audio Coprocessor
    driver: snd_rn_pci_acp3x v: kernel bus-ID: 04:00.5
  Device-3: Advanced Micro Devices [AMD] Ryzen HD Audio
    driver: snd_hda_intel v: kernel bus-ID: 04:00.6
  Device-4: Generic USB Audio driver: hid-generic,snd-usb-audio,usbhid
    type: USB bus-ID: 3-1.2.3.1:8
  API: ALSA v: k6.19.8-arch1-1 status: kernel-api
  Server-1: sndiod v: N/A status: off
  Server-2: PipeWire v: 1.6.2 status: active
Network:
  Device-1: Realtek RTL8111/8168/8211/8411 PCI Express Gigabit Ethernet
    driver: r8169 v: kernel port: f000 bus-ID: 01:00.0
  IF: enp1s0 state: down mac: <filter>
  Device-2: Intel Wi-Fi 6 AX200 driver: iwlwifi v: kernel bus-ID: 02:00.0
  IF: wlan0 state: up mac: <filter>
  Device-3: Realtek USB 10/100/1000 LAN driver: r8152 type: USB
    bus-ID: 4-1.2.3:5
  IF: enp4s0f4u1u2u3 state: down mac: <filter>
  IF-ID-1: virbr0 state: up speed: 10000 Mbps duplex: unknown
    mac: <filter>
  IF-ID-2: vnet0 state: unknown speed: 10000 Mbps duplex: full
    mac: <filter>
Bluetooth:
  Device-1: N/A driver: btusb v: 0.8 type: USB bus-ID: 3-3:3
  Report: rfkill ID: hci0 rfk-id: 0 state: up address: see --recommends
Drives:
  Local Storage: total: 942.7 GiB used: 67.4 GiB (7.1%)
  ID-1: /dev/nvme0n1 model: 512GB SSD size: 476.94 GiB temp: 50.9 C
  ID-2: /dev/sda vendor: Crucial model: CT500BX500SSD1 size: 465.76 GiB
Partition:
  ID-1: / size: 463.74 GiB used: 67.21 GiB (14.5%) fs: btrfs dev: /dev/dm-0
    mapped: root
  ID-2: /boot size: 2 GiB used: 200.7 MiB (9.8%) fs: vfat dev: /dev/sda1
  ID-3: /home size: 463.74 GiB used: 67.21 GiB (14.5%) fs: btrfs
    dev: /dev/dm-0 mapped: root
  ID-4: /var/log size: 463.74 GiB used: 67.21 GiB (14.5%) fs: btrfs
    dev: /dev/dm-0 mapped: root
Swap:
  ID-1: swap-1 type: file size: 28.29 GiB used: 0 KiB (0.0%)
    file: /swap/swapfile
  ID-2: swap-2 type: zram size: 14.14 GiB used: 0 KiB (0.0%)
    dev: /dev/zram0
USB:
  Hub-1: 1-0:1 info: hi-speed hub with single TT ports: 4 rev: 2.0
    speed: 480 Mb/s chip-ID: 1d6b:0002
  Device-1: 1-1:2 info: Logitech USB Receiver type: keyboard,mouse,HID
    driver: logitech-djreceiver,usbhid rev: 2.0 speed: 12 Mb/s
    chip-ID: 046d:c53f
  Hub-2: 2-0:1 info: super-speed hub ports: 2 rev: 3.1 speed: 10 Gb/s
    chip-ID: 1d6b:0003
  Hub-3: 3-0:1 info: hi-speed hub with single TT ports: 4 rev: 2.0
    speed: 480 Mb/s chip-ID: 1d6b:0002
  Hub-4: 3-1:2 info: hi-speed hub with multiple TTs ports: 5 rev: 2.1
    speed: 480 Mb/s chip-ID: 2109:2822
  Hub-5: 3-1.2:4 info: hi-speed hub with single TT ports: 4 rev: 2.1
    speed: 480 Mb/s chip-ID: 05e3:0610
  Device-1: 3-1.2.1:10 info: ZSA Labs Voyager type: keyboard,HID,mouse
    driver: hid-generic,usbhid rev: 2.0 speed: 12 Mb/s chip-ID: 3297:1977
  Hub-6: 3-1.2.3:7 info: hi-speed hub with single TT ports: 4 rev: 2.0
    speed: 480 Mb/s chip-ID: 05e3:0608
  Device-1: 3-1.2.3.1:8 info: Generic USB Audio type: audio,HID
    driver: hid-generic,snd-usb-audio,usbhid rev: 2.0 speed: 480 Mb/s
    chip-ID: 0bda:4ef1
  Device-2: 3-1.5:5 info: VIA Labs USB Billboard Device type: billboard
    driver: N/A rev: 2.0 speed: 480 Mb/s chip-ID: 2109:8822
  Device-3: 3-3:3 info: N/A type: bluetooth driver: btusb rev: 2.0
    speed: 12 Mb/s chip-ID: 8087:0029
  Hub-7: 4-0:1 info: super-speed hub ports: 2 rev: 3.1 speed: 10 Gb/s
    chip-ID: 1d6b:0003
  Hub-8: 4-1:2 info: super-speed hub ports: 4 rev: 3.2 speed: 10 Gb/s
    chip-ID: 2109:0822
  Hub-9: 4-1.2:3 info: super-speed hub ports: 4 rev: 3.2 speed: 5 Gb/s
    chip-ID: 05e3:0626
  Device-1: 4-1.2.2:4 info: Generic USB3.0 Card Reader type: mass storage
    driver: usb-storage rev: 3.2 speed: 5 Gb/s chip-ID: 05e3:0749
  Device-2: 4-1.2.3:5 info: Realtek USB 10/100/1000 LAN type: Network
    driver: r8152 rev: 3.2 speed: 5 Gb/s chip-ID: 0bda:8153
Sensors:
  System Temperatures: cpu: 55.6 C mobo: N/A gpu: amdgpu temp: 53.0 C
  Fan Speeds (rpm): N/A
Info:
  Memory: total: 28 GiB note: est. available: 28.29 GiB
    used: 12.25 GiB (43.3%)
  Processes: 503 Uptime: 32m Init: systemd
  Packages: 1160 Compilers: clang: 22.1.1 gcc: 15.2.1 Shell: Zsh v: 5.9
    inxi: 3.3.40
```
</details>
