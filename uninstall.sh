#!/usr/bin/env bash
set -euo pipefail

# rtw89 driver uninstall script
# Reference: https://github.com/Zeknes/rtw89 README.md

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "========================================"
echo " rtw89 driver uninstaller"
echo "========================================"
echo ""

# Detect install method
INSTALL_METHOD="dkms"
if [[ "${1:-}" == "--make" ]]; then
    INSTALL_METHOD="make"
fi

if [[ "${INSTALL_METHOD}" == "dkms" ]]; then
    echo "Step 1: Detect installed rtw89 DKMS version..."
    DKMS_STATUS=$(sudo dkms status rtw89 2>/dev/null || true)
    if [[ -z "${DKMS_STATUS}" ]]; then
        echo "WARNING: No rtw89 DKMS module found."
    else
        echo "Found: ${DKMS_STATUS}"
        # Parse version from dkms status output, e.g. "rtw89/7.0, 6.19.10-200.fc43.x86_64, x86_64: installed"
        VERSION=$(echo "${DKMS_STATUS}" | grep -oP 'rtw89/\K[0-9.]+' | head -n1)
        if [[ -n "${VERSION}" ]]; then
            echo "Removing rtw89/${VERSION} from DKMS..."
            sudo dkms remove "rtw89/${VERSION}" --all
            if [[ -d "/usr/src/rtw89-${VERSION}" ]]; then
                sudo rm -rf "/usr/src/rtw89-${VERSION}"
            fi
        else
            echo "WARNING: Could not parse DKMS version. Please remove manually:"
            echo "         sudo dkms remove rtw89/<version> --all"
            echo "         sudo rm -rf /usr/src/rtw89-<version>"
        fi
    fi
else
    echo "Step 1: Uninstall driver built via make..."
    sudo make uninstall
fi

echo ""
echo "Step 2: Remove configuration files..."
sudo rm -f /etc/modprobe.d/rtw89.conf
sudo rm -f /etc/modprobe.d/usb_storage.conf

echo ""
echo "========================================"
echo " Uninstallation complete!"
echo "========================================"
