#!/bin/bash
set -euo pipefail

trap 'echo; gum log --level error "Cancelled"; exit 130' INT

# Check for sudo/doas first
if command -v sudo &>/dev/null; then SUDO=sudo; elif command -v doas &>/dev/null; then SUDO=doas; else echo "Error: Need sudo or doas"; exit 1; fi

# Check and install gum if needed
if ! command -v gum &>/dev/null; then
    echo "Installing gum..."
    if command -v pacman &>/dev/null; then
        $SUDO pacman -S --needed --noconfirm gum
    elif command -v apt &>/dev/null; then
        $SUDO apt update && $SUDO apt install -y gum
    elif command -v dnf &>/dev/null; then
        $SUDO dnf install -y gum
    else
        echo "Error: Unsupported package manager"; exit 1
    fi
fi

# Setup
echo
gum log --level info "Virtualization Setup Tool"
echo

# Detect tools
[[ -z "${SHELL:-}" ]] && { gum log --level error "SHELL not set"; exit 1; }

if command -v pacman &>/dev/null; then PM=pacman; PM_INST="-S --needed --noconfirm"; PM_CHK="-Q"
elif command -v apt &>/dev/null; then PM=apt; PM_INST="install -y"; PM_CHK="list --installed"
elif command -v dnf &>/dev/null; then PM=dnf; PM_INST="install -y"; PM_CHK="list --installed"
else gum log --level error "Unsupported package manager"; exit 1; fi

install_pkg() {
    if command -v "$1" >/dev/null 2>&1; then
        gum style --foreground 2 "  ✓ $2" --faint "(already installed)"
        return 0
    fi

    if ! gum confirm --default=true "  Install $2?"; then
        gum style --foreground 3 "  ⊘ Skipped $2"
        return 0
    fi

    if $SUDO $PM $PM_INST "$3" 2>&1 | gum spin --title "Installing $2..." --show-output; then
        gum style --foreground 2 "  ✓ Installed $2"
    else
        gum style --foreground 1 "  ✗ Failed to install $2"
        return 1
    fi
}

remove_pkg() {
    if ! command -v "$1" >/dev/null 2>&1; then
        gum style --foreground 2 "  ✓ $2" --faint "(not installed)"
        return 0
    fi

    if ! gum confirm --default=false "  Remove $2?"; then
        gum style --foreground 3 "  ⊘ Kept $2"
        return 0
    fi

    if [[ "$PM" == "pacman" ]]; then
        if $SUDO $PM -Rdd --noconfirm "$3" 2>&1 | gum spin --title "Removing $2..." --show-output; then
            gum style --foreground 2 "  ✓ Removed $2"
        else
            gum style --foreground 1 "  ✗ Failed to remove $2"
            return 1
        fi
    else
        if $SUDO $PM remove -y "$3" 2>&1 | gum spin --title "Removing $2..." --show-output; then
            gum style --foreground 2 "  ✓ Removed $2"
        else
            gum style --foreground 1 "  ✗ Failed to remove $2"
            return 1
        fi
    fi
}

setup_kvm() {
    if [[ ! -e /dev/kvm ]]; then
        gum style --foreground 1 "  ✗ KVM not available (enable in BIOS/UEFI)"
        return 1
    fi

    gum spin --title "Setting up KVM..." -- $SUDO usermod "$USER" -aG kvm
    gum style --foreground 2 "  ✓ KVM configured"
    gum style --foreground 3 "  ⓘ Log out and back in for group changes to take effect"
}

setup_libvirt() {
    echo
    gum log --level info "Configuring Libvirt"
    echo

    gum spin --title "Installing dependencies..." -- $SUDO $PM $PM_INST dnsmasq iptables-nft
    gum spin --title "Adding user to libvirt group..." -- $SUDO usermod "$USER" -aG libvirt

    [[ "$PM" == "pacman" ]] && gum spin --title "Configuring firewall..." -- $SUDO sed -i 's/^#\?firewall_backend.*/firewall_backend = "iptables"/' /etc/libvirt/network.conf

    gum spin --title "Enabling libvirtd..." -- $SUDO systemctl enable --now libvirtd.service
    gum spin --title "Setting up network..." -- $SUDO virsh net-autostart default 2>/dev/null || true

    gum style --foreground 2 "  ✓ Libvirt configured"
    echo
    setup_kvm
}

# Main menu
ACTION=$(gum choose --cursor.foreground 5 "Install" "Remove" "Exit")

case "$ACTION" in
    Exit) gum log --level info "Goodbye!"; exit 0 ;;
    Install)
        echo
        CHOICE=$(gum choose --cursor.foreground 5 "QEMU" "QEMU-Emulators" "Libvirt" "Virt-Manager" "All" "Cancel")
        echo
        case "$CHOICE" in
            QEMU) install_pkg qemu-img "QEMU" "qemu-desktop" && setup_kvm ;;
            QEMU-Emulators) install_pkg qemu-system-x86_64 "QEMU-Emulators" "qemu-emulators-full" ;;
            Libvirt) install_pkg libvirtd "Libvirt" "libvirt libvirt-dbus" && setup_libvirt ;;
            Virt-Manager) install_pkg virt-manager "Virt-Manager" "virt-manager" ;;
            All)
                install_pkg qemu-img "QEMU" "qemu-desktop" && setup_kvm
                echo
                install_pkg qemu-system-x86_64 "QEMU-Emulators" "qemu-emulators-full"
                echo
                install_pkg libvirtd "Libvirt" "libvirt libvirt-dbus" && setup_libvirt
                echo
                install_pkg virt-manager "Virt-Manager" "virt-manager"
                ;;
        esac
        ;;
    Remove)
        echo
        CHOICE=$(gum choose --cursor.foreground 5 "QEMU" "QEMU-Emulators" "Libvirt" "Virt-Manager" "All" "Cancel")
        echo
        case "$CHOICE" in
            QEMU) remove_pkg qemu-img "QEMU" "qemu-desktop" ;;
            QEMU-Emulators) remove_pkg qemu-system-x86_64 "QEMU-Emulators" "qemu-emulators-full" ;;
            Libvirt) remove_pkg libvirtd "Libvirt" "libvirt libvirt-dbus" ;;
            Virt-Manager) remove_pkg virt-manager "Virt-Manager" "virt-manager" ;;
            All)
                remove_pkg virt-manager "Virt-Manager" "virt-manager"
                echo
                remove_pkg libvirtd "Libvirt" "libvirt libvirt-dbus"
                echo
                remove_pkg qemu-system-x86_64 "QEMU-Emulators" "qemu-emulators-full"
                echo
                remove_pkg qemu-img "QEMU" "qemu-desktop"
                ;;
        esac
        ;;
esac

echo
gum style --foreground 2 --bold "✓ All done!"
echo
