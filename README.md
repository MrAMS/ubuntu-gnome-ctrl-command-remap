# Ctrl/Command Keyboard Remap for Ubuntu Gnome Desktop

**Use Win+C/Win+V like ⌘ Command for copy/paste on both GUI Apps and Gnome Terminals**

This keyboard remap is based on the [Xremap](https://github.com/k0kubun/xremap) functionality and works with Wayland and Xorg.

![Gnome macOS Remap Icon](./resources/gnome-macos-remap-wayland.png#gh-light-mode-only)
![Gnome macOS Remap Icon](./resources/gnome-macos-remap-wayland-dark.png#gh-dark-mode-only)

> This is a different fork of [gnome-macos-remap-wayland](https://github.com/petrstepanov/gnome-macos-remap-wayland) which is focused on using the `Win` key like `Command` key **only**.

## How does it work?
Script downloads the latest version of the `xremap` remapper for your architecture. Configuration file `config.yml` contains majority of the remapping instructions. On top of that the default GNOME shell and Mutter keybindings are modified. A systemd service is created and enabled for a particular user. Therefore after the install other users on the system will not be affected by the remap. 

## Prerequisities
* Install Git and GNOME extensions `sudo <your-package-manager> install git gnome-shell-extensions`.

## Installation
1. Make sure you are running **Wayland** display server. Logout from your session. On the GNOME login screen click ⚙ icon on the bottom right. Select `GNOME` (defaults to Wayland). Log in.
2. Check out this repository run `install.sh` script in Terminal. Script will ask for administrator password.

```
cd ~/Downloads
git clone https://github.com/petrstepanov/gnome-macos-remap-wayland
cd gnome-macos-remap-wayland
chmod +x ./install.sh
./install.sh
```

3. Install and **enable** [this GNOME extension](https://extensions.gnome.org/extension/5060/xremap/) (DO NOT FORGET TO ENABLE IT).
4. Restart your computer.

## How to uninstall

1. If repository was removed, check it out again. Navigate into the program directory in Terminal and run:
```
chmod +x ./uninstall.sh
./uninstall.sh
```

2. Restart your computer.

## Note

### IDE Integrated Terminal
You must config the IDE (e.g. Zed, VSCode) integrated terminal via its settings yourself.
