#!/bin/bash

# Create temporary install directory
BASE_DIR=`pwd`
mkdir -p ~/Downloads && cd ~/Downloads

# Remove previously downloaded archives (if any)
rm -rf ./xremap*

# Detect architecture
ARCH=`uname -m`
echo "INFO: Detected ${ARCH} PC architecture."

# Exit if unsupported architecture
if [ "${ARCH}" != "x86_64" ] && [ "${ARCH}" != "aarch64" ]; then
  echo "ERROR: Unsupported architecture. Please compile and install Xremap manually:"
  echo "       https://github.com/k0kubun/xremap"
  exit 1
fi

# Detect compositor type (X11 or Wayland)
if [ "${XDG_SESSION_TYPE}" == "x11" ]; then
  echo "INFO: Detected X11 compositor."
  ARCHIVE_NAME="xremap-linux-${ARCH}-x11.zip"
elif [ "${XDG_SESSION_TYPE}" == "wayland" ]; then
  echo "INFO: Detected Wayland compositor."
  ARCHIVE_NAME="xremap-linux-${ARCH}-gnome.zip"
else
  echo "ERROR: Unsupported compositor."
  exit 1
fi

# Always download latest xremap release from GitHub
wget https://github.com/xremap/xremap/releases/latest/download/$ARCHIVE_NAME

# Extract the archive
echo "INFO: Extracting the archive..."
if ! command -v unzip &> /dev/null; then
  echo "ERROR: Command \"unzip\" not found."
  exit 0
fi
unzip -o ./xremap-linux-${ARCH}-*.zip

# Remove old binary (if any)
if command -v gnome-terminal &> /dev/null ; then
    echo "INFO: Removing old binary..."
    sudo rm -rf /usr/local/bin/xremap
fi

# Install new binary (if any)
echo "INFO: Installing the binary..."
sudo cp ./xremap /usr/local/bin

# Tweaking server access control for X11
# https://github.com/k0kubun/xremap#x11
if [ "${XDG_SESSION_TYPE}" == "x11" ]; then
  xhost +SI:localuser:root
fi

# Copy Xremap config file with macOS bindings
CONFIG_DIR=~/.config/gnome-macos-remap/
echo "INFO: Copying the xremap config file..."
mkdir -p $CONFIG_DIR
cp $BASE_DIR/config.yml $CONFIG_DIR

# Stop and disable service if already running
if systemctl is-active --user --quiet gnome-macos-remap ; then
  echo "INFO: Stopping and disabling systemd gnome-macos-remap service..."
  systemctl --user stop gnome-macos-remap
  systemctl --user disable gnome-macos-remap
fi

# Copy systemd service file
SERVICE_DIR=~/.local/share/systemd/user/
echo "INFO: Installing systemd service..."
mkdir -p $SERVICE_DIR
cp $BASE_DIR/gnome-macos-remap.service $SERVICE_DIR

# Run Xremap without sudo
# https://github.com/xremap/xremap?tab=readme-ov-file#running-xremap-without-sudo

# User should be able to use `evdev` witout sudo
echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/input.rules
# User should be able to use `uinput` without sudo
sudo gpasswd -a ${USER} input
# Load uinput module at the startup (Debian issue)
echo uinput | sudo tee /etc/modules-load.d/uinput.conf

# Instantiate the service
systemctl --user daemon-reload
systemctl --user enable gnome-macos-remap
systemctl --user start gnome-macos-remap

# Tweak gsettings
echo "INFO: Tweaking GNOME and Mutter keybindings..."

# Ensure default system xkb-options are not turned on - may interfere
gsettings reset org.gnome.desktop.input-sources xkb-options

# Disable overview key ⌘ - interferes with ⌘ + ... combinations
gsettings set org.gnome.mutter overlay-key ''

# Paste in terminal (if set via Ctrl+V, not Shift+Ctrl+V) interferes with default GNOME show notification panel shortcut
gsettings set org.gnome.shell.keybindings toggle-message-tray "[]"

# Setting relocatable schema for Terminal
if command -v gnome-terminal &> /dev/null ; then
    echo "INFO: Found GNOME Terminal. Applying tweaks..."
    gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ copy '<Shift><Super>c'
    gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ paste '<Shift><Super>v'
    gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ new-tab '<Shift><Super>t'
    gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ new-window '<Shift><Super>n'
    gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ close-tab '<Shift><Super>w'
    gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ close-window '<Shift><Super>q'
    gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ find '<Shift><Super>f'
fi

# Restart is required in order for the changes in the `/usr/share/dbus-1/session.conf` to take place
# Therefore cannot launch service right away


# Download and enable Xremap GNOME extension (for Wayland only)
# systemctl --user status gnome-macos-remap
if [ "${XDG_SESSION_TYPE}" == "wayland" ]; then
  # Check if xremap extension is enabled
  if gnome-extensions list | grep -q "xremap@k0kubun.com"; then
    echo "INFO: The xremap extension is already enabled."
  else
    RED=`tput setaf 1`
    RESET=`tput sgr0`
    echo "INFO: ${RED}Action Required${RESET}. Install the xremap extension and restart your PC."
    echo "      https://extensions.gnome.org/extension/5060/xremap/"
  fi
else
  gnome-extensions disable xremap@k0kubun.com
fi

echo "INFO: Computer restart may be required."
