#!/usr/bin/env bash

# create a Linux private bridge
sudo ip link add br88 type bridge

# enable forwarding
sudo echo 1 > /proc/sys/net/ipv4/ip_forward

# create 2 *TAP* devices:
sudo ip tuntap add mode tap tap2
sudo ip tuntap add mode tap tap3

# activate 2 *TAP* devices:
sudo ip link set tap2 up
sudo ip link set tap3 up

# bind 2 *TAP* devices:
sudo ip link set tap2 master br88
sudo ip link set tap3 master br88
sudo ip link set br88 up

# check
sudo brctl show br88

# launch VM2 and VM3:
qemu-system-x86_64 -hda debian_wheezy_amd64_standard2.qcow2 -device e1000,netdev=net0,mac=00:11:22:33:44:02 -netdev tap,id=net0,ifname=tap2,script=no,downscript=no -name vm2 -daemonize
qemu-system-x86_64 -hda debian_wheezy_amd64_standard3.qcow2 -device e1000,netdev=net0,mac=00:11:22:33:44:03 -netdev tap,id=net0,ifname=tap3,script=no,downscript=no -name vm3 -daemonize