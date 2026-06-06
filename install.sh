#!/bin/bash

# ==============================================================================
# Dolphin Billing Warnet SDDM Theme - Installer Script
# Author: M Faisal Asrozy (https://github.com/asrozy98)
# Description: Installs the theme and auto-detects system PAM faillock settings.
# ==============================================================================

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Please run this installer as root (e.g., using sudo)."
    exit 1
fi

THEME_NAME="Billing-Warnet"
INSTALL_DIR="/usr/share/sddm/themes/$THEME_NAME"
SOURCE_DIR="$(dirname "$(readlink -f "$0")")"

echo "=== Installing SDDM Theme: $THEME_NAME ==="

# 1. Create target directory and copy files
echo "Copying theme files to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp -r "$SOURCE_DIR"/* "$INSTALL_DIR/"

# Remove the installer itself from the installed directory to keep it clean
rm -f "$INSTALL_DIR/install.sh"

# 2. Auto-detect PAM faillock settings
UNLOCK_TIME=60
DENY_ATTEMPTS=3

if [ -f /etc/security/faillock.conf ]; then
    echo "Scanning /etc/security/faillock.conf for lockout configurations..."
    
    # Extract unlock_time value (check uncommented first, then commented-out default)
    DETECTED_TIME=$(grep -E "^\s*unlock_time\s*=" /etc/security/faillock.conf | awk -F= '{print $2}' | tr -d '[:space:]')
    if [ -z "$DETECTED_TIME" ]; then
        DETECTED_TIME=$(grep -E "^\s*#\s*unlock_time\s*=" /etc/security/faillock.conf | awk -F= '{print $2}' | tr -d '[:space:]')
    fi
    
    if [ ! -z "$DETECTED_TIME" ]; then
        UNLOCK_TIME=$DETECTED_TIME
        echo "-> Detected system unlock_time: ${UNLOCK_TIME} seconds"
    fi

    # Extract deny value (check uncommented first, then commented-out default)
    DETECTED_DENY=$(grep -E "^\s*deny\s*=" /etc/security/faillock.conf | awk -F= '{print $2}' | tr -d '[:space:]')
    if [ -z "$DETECTED_DENY" ]; then
        DETECTED_DENY=$(grep -E "^\s*#\s*deny\s*=" /etc/security/faillock.conf | awk -F= '{print $2}' | tr -d '[:space:]')
    fi
    
    if [ ! -z "$DETECTED_DENY" ]; then
        DENY_ATTEMPTS=$DETECTED_DENY
        echo "-> Detected system maximum login attempts: ${DENY_ATTEMPTS}"
    fi
else
    echo "Info: /etc/security/faillock.conf not found. Using standard OS defaults (3 attempts, 600s lockout)."
fi

# 3. Update theme.conf with the detected system values
CONF_FILE="$INSTALL_DIR/theme.conf"
CONF_USER_FILE="$INSTALL_DIR/theme.conf.user"

echo ""
echo "Lockout settings to apply:"
echo "  - Maximum Login Attempts: $DENY_ATTEMPTS"
echo "  - Lockout Duration      : $UNLOCK_TIME seconds"
echo ""
echo "Applying detected settings to configuration files..."

for file in "$CONF_FILE" "$CONF_USER_FILE"; do
    if [ -f "$file" ]; then
        # Replace or append lockoutAttempts
        if grep -q "lockoutAttempts" "$file"; then
            sed -i "s/lockoutAttempts=.*/lockoutAttempts=$DENY_ATTEMPTS/" "$file"
        else
            echo "lockoutAttempts=$DENY_ATTEMPTS" >> "$file"
        fi

        # Replace or append lockoutDuration
        if grep -q "lockoutDuration" "$file"; then
            sed -i "s/lockoutDuration=.*/lockoutDuration=$UNLOCK_TIME/" "$file"
        else
            echo "lockoutDuration=$UNLOCK_TIME" >> "$file"
        fi
    fi
done

echo "=== Installation Completed Successfully ==="
echo "To enable this theme, update your /etc/sddm.conf or sddm.conf.d configuration file:"
echo "  [Theme]"
echo "  Current=$THEME_NAME"
echo ""
echo "Or select it via your Desktop Environment Settings (e.g., KDE System Settings -> Login Screen)."
