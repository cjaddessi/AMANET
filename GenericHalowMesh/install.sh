#!/bin/bash

set -e

echo "[+] Starting mesh node setup..."

# -------------------------
# Variables
# -------------------------
MESH_IF="wlan1"
LAN_IF="eth0"
MESH_ID="test"
MESH_FREQ="2437"
LAN_IP="10.10.232.1"
LAN_NETMASK="255.255.255.0"
DHCP_RANGE_START="10.10.232.2"
DHCP_RANGE_END="10.10.232.2"   

# -------------------------
# Update + install packages
# -------------------------
echo "[+] Installing packages..."
apt update
apt install -y babeld dnsmasq iw ifupdown

# -------------------------
# Stop conflicting network managers
# -------------------------
echo "[+] Disabling conflicting network managers..."

# Disable dhcpcd entirely (Raspbian default)
systemctl stop dhcpcd || true
systemctl disable dhcpcd || true

# Tell NetworkManager to ignore these interfaces (if NM is installed)
if systemctl is-active --quiet NetworkManager; then
    echo "[+] Marking interfaces unmanaged in NetworkManager..."
    mkdir -p /etc/NetworkManager/conf.d
    cat > /etc/NetworkManager/conf.d/unmanaged.conf <<EOF
[keyfile]
unmanaged-devices=interface-name:${MESH_IF};interface-name:${LAN_IF}
EOF
    systemctl restart NetworkManager
fi

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
# Configure network interfaces (ifupdown)
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
    pre-up iw dev ${MESH_IF} set type mp || true
    pre-up ip link set ${MESH_IF} up
    post-up iw dev ${MESH_IF} mesh join ${MESH_ID} freq ${MESH_FREQ} || true
    post-down iw dev ${MESH_IF} mesh leave || true
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
# Bring up interfaces manually NOW
# (don't wait for reboot to find out it's broken)
# -------------------------
echo "[+] Bringing up interfaces..."

# eth0
ip link set ${LAN_IF} down || true
ip addr flush dev ${LAN_IF} || true
ip link set ${LAN_IF} up
ip addr add ${LAN_IP}/24 dev ${LAN_IF}

# wlan1 mesh
ip link set ${MESH_IF} down || true
iw dev ${MESH_IF} set type mp
ip link set ${MESH_IF} up
iw dev ${MESH_IF} mesh join ${MESH_ID} freq ${MESH_FREQ}

# -------------------------
# Verify
# -------------------------
echo "[+] Interface status:"
ip a show ${LAN_IF}
ip a show ${MESH_IF}
iw dev ${MESH_IF} info

# -------------------------
# Restart services
# -------------------------
echo "[+] Restarting services..."
systemctl restart babeld
systemctl restart dnsmasq

echo "[+] Setup complete. Reboot recommended to verify persistence."