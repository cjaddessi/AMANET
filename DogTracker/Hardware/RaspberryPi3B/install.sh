#!/bin/bash

set -e

echo "[+] Starting mesh node setup..."

# -------------------------
# Variables (edit if needed)
# -------------------------
MESH_IF="wlan1"
LAN_IF="eth0"
MESH_ID="test"
MESH_FREQ="2437"
LAN_IP="10.10.232.1" # needs to be derrived from ipv6 that gets set on wlan the .232 is to be derrived from last half of the second. ex e8 = 232
LAN_NETMASK="255.255.255.0"
DHCP_RANGE_START="10.10.232.2"
DHCP_RANGE_END="10.10.232.2"

# -------------------------
# Update + install packages
# -------------------------
echo "[+] Installing packages..."
apt update
apt install -y babeld dnsmasq iw

# -------------------------
# Configure babeld
# -------------------------
echo "[+] Configuring babeld..."
cat > /etc/babeld.conf <<EOF
interface ${MESH_IF} type wireless

interface ${LAN_IF}
  redistribute
EOF

systemctl enable babeld

# -------------------------
# Configure network interfaces
# -------------------------
echo "[+] Configuring /etc/network/interfaces..."
cat > /etc/network/interfaces <<EOF
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto ${LAN_IF}
iface ${LAN_IF} inet static
    address ${LAN_IP}
    netmask ${LAN_NETMASK}

auto ${MESH_IF}
iface ${MESH_IF} inet6 manual
    pre-up ip link set ${MESH_IF} down || true
    pre-up iw dev ${MESH_IF} set type mp
    pre-up ip link set ${MESH_IF} up
    post-up iw dev ${MESH_IF} mesh join ${MESH_ID} freq ${MESH_FREQ}
EOF

# -------------------------
# Enable IPv6 forwarding
# -------------------------
echo "[+] Enabling IPv6 forwarding..."
grep -q "net.ipv6.conf.all.forwarding=1" /etc/sysctl.conf || \
echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf

sysctl -p

# -------------------------
# Configure dnsmasq
# -------------------------
echo "[+] Configuring dnsmasq..."
cat > /etc/dnsmasq.conf <<EOF
interface=${LAN_IF}
bind-interfaces

dhcp-range=${DHCP_RANGE_START},${DHCP_RANGE_END},12h
dhcp-option=3,${LAN_IP}
EOF

systemctl enable dnsmasq

# -------------------------
# Restart services
# -------------------------
echo "[+] Restarting services..."
systemctl restart babeld
systemctl restart dnsmasq

echo "[+] Setup complete. Reboot recommended."

# -------------------------
# Enable ATAK script to run 
# -------------------------