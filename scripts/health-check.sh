#!/bin/bash

echo "=== Health Check ==="
echo "Hostname: $(hostname)"
echo "Current time: $(date)"

echo "Disk usage:"
df -h /

echo "Memory usage:"
free -h

echo "Health check completed"
