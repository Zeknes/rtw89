#!/usr/bin/env bash
set -euo pipefail

# rtw89 driver install script
# Reference: https://github.com/Zeknes/rtw89 README.md

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "========================================"
echo " rtw89 driver installer"
echo "========================================"
echo ""

# Detect install method
INSTALL_METHOD="dkms"
if [[ "${1:-}" == "--make" ]]; then
    INSTALL_METHOD="make"
fi

echo "Step 1: Remove previously installed out-of-kernel rtw89 drivers..."
sudo make cleanup_target_system

echo ""
echo "Step 2: Build and install the driver via ${INSTALL_METHOD}..."
if [[ "${INSTALL_METHOD}" == "dkms" ]]; then
    if ! command -v dkms &>/dev/null; then
        echo "ERROR: dkms is not installed. Please install dkms first,"
        echo "       or run: ./install.sh --make"
        exit 1
    fi
    sudo dkms install "${PWD}"
else
    make clean modules
    sudo make install
fi

echo ""
echo "Step 3: Install firmware..."
sudo make install_fw

echo ""
echo "Step 4: Copy rtw89.conf to /etc/modprobe.d/..."
sudo cp -v rtw89.conf /etc/modprobe.d/

echo ""
echo "========================================"
echo " Installation complete!"
echo "========================================"

if [[ "${INSTALL_METHOD}" == "dkms" ]]; then
    echo ""
    echo "NOTE: If Secure Boot is enabled, you may need to enroll the MOK:"
    echo "      sudo mokutil --import /var/lib/dkms/mok.pub"
    echo "      (For Ubuntu-based distros, use /var/lib/shim-signed/mok/MOK.der instead)"
fi

echo ""
echo "Optional: If a USB Wi-Fi adapter causes long boot times,"
echo "          copy usb_storage.conf to /etc/modprobe.d/:"
echo "          sudo cp -v usb_storage.conf /etc/modprobe.d/"
echo "          sudo update-initramfs -u -k all"
