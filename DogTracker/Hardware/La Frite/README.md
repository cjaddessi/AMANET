# 🖥️ Libre Computer Board — Node Setup Guide

> A step-by-step guide to flashing Raspbian Bookworm to eMMC and bootstrapping a node environment on a Libre Computer board.

---

## 📋 Prerequisites

Before you begin, make sure you have the following ready:

- Libre Computer board with **eMMC or other storage media already installed**
- USB keyboard
- USB drive (to boot the OS installer)
- Ethernet cable
- USB Ethernet adapter (for management interface)

---

## 🚀 Setup Steps

### Step 1 — Download & Flash the OS to USB

Download the Raspbian Bookworm image and flash it to your USB drive:

```
https://distro.libre.computer/ci/raspbian/12/2023-10-10-raspbian-bookworm-arm64-lite+arm64.img.xz
```

> **Tip:** Use [Balena Etcher](https://etcher.balena.io/) or `dd` to flash the image to your USB drive.

---

### Step 2 — Connect Hardware

Plug in the following before powering on:

- 🔌 Ethernet cable
- ⌨️ USB keyboard
- 💾 USB drive (with the flashed OS)
- ✅ Ensure eMMC or target storage is already seated on the board

---

### Step 3 — Power On

Power on the board and boot from the USB drive.

---

### Step 4 — Create User

During first-boot setup, create the following user:

```
Username: nodeuser
```

---

### Step 5 — Enable SSH

Make remote access easier by starting SSH:

```bash
sudo systemctl start ssh
```

---

### Step 6 — Download the OS Image Locally

From within the booted system, download the Raspbian image to flash to eMMC:

```bash
wget https://distro.libre.computer/ci/raspbian/12/2023-10-10-raspbian-bookworm-arm64-lite+arm64.img.xz
```

---

### Step 7 — Install Dependencies & rpi-imager

Update the system and install the tools needed to flash the image:

```bash
sudo apt update
sudo apt install rpi-imager
sudo apt install libegl1-mesa libgl1-mesa-glx
sudo apt install libopengl0
```

---

### Step 8 — Flash the Image to eMMC

Use `rpi-imager` in CLI mode to flash the downloaded image to the eMMC chip:

```bash
sudo rpi-imager --cli 2023-10-10-raspbian-bookworm-arm64-lite+arm64.img.xz /dev/mmcblk0
```

> ⚠️ **Warning:** This will overwrite everything on `/dev/mmcblk0`. Double-check you're targeting the correct device.

---

### Step 9 — Shut Down the Board

```bash
sudo shutdown now
```

---

### Step 10 — Remove the USB Drive

Unplug the USB storage device so the board will boot from eMMC on next power-on.

---

### Step 11 — Boot from eMMC & Configure

Power the board back on. It will now boot from eMMC. Use the keyboard to configure your user, then enable and start SSH:

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

---

### Step 12 — Connect Management Interface

Plug in your **USB Ethernet adapter** — this will serve as the **management interface**.

---

### Step 13 — Connect Internet

Plug an **Ethernet cable** into the USB Ethernet adapter to provide internet access to the management interface.

---

### Step 14 — Run the Install Script

Copy the `install.sh` script to the board and execute it:

```bash
sudo ./install.sh
```

---

## 🗂️ Directory Structure

```
.
├── install.sh       # Main installation and configuration script
└── README.md        # This file
```

---

## 🛠️ Troubleshooting

| Issue | Solution |
|---|---|
| Board won't boot from USB | Check your boot order in the bootloader settings |
| `/dev/mmcblk0` not found | Ensure eMMC module is properly seated on the board |
| SSH not connecting | Confirm SSH is started: `sudo systemctl status ssh` |
| `rpi-imager` fails to launch | Re-run the dependency installs in Step 7 |

---

## 📄 License

This project is open source. See [LICENSE](./LICENSE) for details.

---

*Built for Libre Computer boards running Raspbian Bookworm (arm64)*
