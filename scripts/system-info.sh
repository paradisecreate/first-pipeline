#!/bin/bash

echo "=== System Information ==="
echo "Hostname: $(hostname)"
echo "Current user: $(whoami)"
echo "Kernel version: $(uname -r)"

echo "Operating system:"
cat /etc/os-release
