#!/bin/bash
# maelstrom-audio-fix: uninstaller
# Github: https://github.com/M4elstr0m/linux-audio-fix
# By M4elstr0m
set -e

SERVICE_NAME="maelstrom-audio-fix.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with sudo."
    echo "  Aborting."
    exit 1
fi

echo ""
echo "> Stopping and disabling the service"
systemctl disable --now "$SERVICE_NAME" 2>/dev/null || true
echo "  Done (no error if it was already absent)."

echo ""
echo "> Removing the service file"
rm -f "$SERVICE_PATH"
echo "  Removed $SERVICE_PATH"

echo ""
echo "> Reloading systemd"
systemctl daemon-reload
systemctl reset-failed 2>/dev/null || true

echo ""
echo "> Resetting the memory clock live"
NVIDIA_SMI_PATH="$(command -v nvidia-smi || true)"
if [ -n "$NVIDIA_SMI_PATH" ]; then
    "$NVIDIA_SMI_PATH" --reset-memory-clocks 2>/dev/null || true
    echo "  Memory clock reset, no reboot needed."
else
    echo "  nvidia-smi not found, skipping live clock reset. Please reboot to make sure the fix is inactive."
fi

echo ""
echo "> Uninstallation complete"
