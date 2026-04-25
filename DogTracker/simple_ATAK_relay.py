#!/usr/bin/env python3

import socket
import struct

LAN_IP = "10.10.232.1" # Ehternet client port side
DEST = "10.10.166.243" # Handler Client device ip

ATAK_ENDPOINTS = [
    ("239.2.3.1", 6969),
    ("239.5.5.55", 7171),
    ("224.10.10.1", 17012),
]

sockets = []
send = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

for group, port in ATAK_ENDPOINTS:

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind(('', port))

    mreq = struct.pack(
        "4s4s",
        socket.inet_aton(group),
        socket.inet_aton(LAN_IP)
    )

    sock.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreq)

    sockets.append((sock, port))

    print(f"Listening {group}:{port}")

print("Forwarding ATAK traffic to", DEST)

while True:

    for sock, port in sockets:

        sock.settimeout(0.1)

        try:
            data, addr = sock.recvfrom(4096)

            print(f"Packet {addr} → {DEST}:{port}")

            send.sendto(data, (DEST, port))

        except socket.timeout:
            pass