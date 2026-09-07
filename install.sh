#!/bin/bash
# maelstrom-audio-fix: Prevent HDMI audio glitches caused by memory clock frequency transitions on Linux for hybrid graphics laptops.
# Github: https://github.com/M4elstr0m/linux-audio-fix
# By M4elstr0m
set -e

SERVICE_NAME="maelstrom-audio-fix.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
MEM_CLOCK="12001"

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with sudo."
    echo "  Aborting."
    exit 1
fi

echo ""
echo "> Locating nvidia-smi"
NVIDIA_SMI_PATH="$(command -v nvidia-smi || true)"
if [ -z "$NVIDIA_SMI_PATH" ]; then
    echo "  nvidia-smi not found in PATH. The proprietary NVIDIA driver is required."
    echo "      Aborting."
    exit 1
fi
echo "  Found nvidia-smi at: $NVIDIA_SMI_PATH"

echo ""
echo "> Checking that $MEM_CLOCK MHz is a valid supported memory clock"
if ! "$NVIDIA_SMI_PATH" -q -d SUPPORTED_CLOCKS | grep -q "Memory *: $MEM_CLOCK MHz"; then
    echo "  $MEM_CLOCK MHz is not supported, picking the highest supported memory clock instead."
    MEM_CLOCK="$("$NVIDIA_SMI_PATH" -q -d SUPPORTED_CLOCKS | grep -oP 'Memory\s*:\s*\K[0-9]+' | sort -n | tail -1)"
    if [ -z "$MEM_CLOCK" ]; then
        echo "      Could not determine a supported memory clock."
        echo "          Aborting."
        exit 1
    fi
    echo "      Using $MEM_CLOCK MHz instead."
fi

echo ""
echo "> Writing the systemd service (overwrites any previous version)"
cat >"$SERVICE_PATH" <<EOF
[Unit]
Description=Maelstrom's audio fix (https://github.com/M4elstr0m/linux-audio-fix) - Prevent HDMI audio glitches caused by memory clock frequency transitions on Linux for hybrid graphics laptops.
After=multi-user.target

[Service]
Type=oneshot
ExecStart=$NVIDIA_SMI_PATH -pm 1
ExecStart=$NVIDIA_SMI_PATH --lock-memory-clocks=$MEM_CLOCK,$MEM_CLOCK
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo ""
echo "> Reloading systemd"
systemctl daemon-reload

echo ""
echo "> Enabling and starting the fix"
systemctl enable --now "$SERVICE_NAME"

echo ""
echo "> Installation complete"
