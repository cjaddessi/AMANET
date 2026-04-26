# 🖥️ Rasbperry PI Board — Node Setup Guide

> A step-by-step guide to flashing Raspbian to a node environment on a Raspberry PI board.

---

## 📋 Prerequisites

Before you begin, make sure you have the following ready:

- Raspberry PI board & Power Source
- Micro SD card
- 2.4 GhZ USB NIC [Network Card with Mesh capabilites ex. AR9271](https://www.amazon.com/dp/B07FVRKCZJ?ref=ppx_yo2ov_dt_b_fed_asin_title)
- Ethernet cable (for client devices)
- built in wifi card (for management interface)
- USB-C ethernet adapter for Client Android device

---

## 🚀 Setup Steps

### Step 1 — Download & Flash the OS to Micro SD card

Download the Raspberry PI Imager tool, Select your device ex. "Raspberry Pi 3" -> "Raspberry PI OS (64-bit)" -> Configure Hostname "node" -> Timezone "UTC" -> Username: "nodeuser" -> Choose WiFI -> Enable SSH: "Authentication Mechanism: Use Password" -> Enable Raspbery Pi Connect: "OFF" -> Write. 

```
https://www.raspberrypi.com/software/
```

---

### Step 2 — Connect Hardware

Plug in the following before powering on:

- 💾 Mircro SD card (with the flashed OS)

---

### Step 3 — Power On

Power on the board and boot from the Mirco SD Card..

---

### Step 4 — Connect WAN Interface device(s) 

Wait about 1 minute before plugging in devices:
- 🛜 2.4 Ghz USB NIC


---

### Step 5 — Connect to PI for Managment

You may need to login to your router or perform a network scan to find your pi on the network, Once the IP has been located connect via ssh using the "nodeuser" account.

---

### Step 6 — Download the Install.sh from this Git Repo

From within the booted system, download the Raspbian image to flash to eMMC:

```bash
sudo apt update
sudo apt upgrade
wget https://raw.githubusercontent.com/cjaddessi/AMANET/main/DogTracker/Hardware/RaspberryPi3B/install.sh
chmod 777 install.sh
sudo ./install.sh
```
> **Tip:** Run Each Command individually

---

### Step 7 — Reboot Device

Change permissions on file so that it can be executed, Then execute file as sudo user

```bash
chmod 777 install.sh
sudo .\install.sh
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

*Built for Raspberry PI boards running Raspbian Bookworm (arm64)*
