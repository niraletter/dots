#!/usr/bin/env bash

C_OK="76"; C_ERR="196"; C_WARN="220"; C_DIM="245"; C_TITLE="141"; C_INFO="117"

SPINNERS=(line dot minidot jump pulse points moon meter hamburger)

if ! command -v gum &>/dev/null; then
    echo "Installing gum..."
    if   command -v pacman &>/dev/null; then sudo pacman -S --needed --noconfirm gum
    elif command -v apt    &>/dev/null; then
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key \
            | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" \
            | sudo tee /etc/apt/sources.list.d/charm.list
        sudo apt update && sudo apt install -y gum
    elif command -v dnf    &>/dev/null; then
        printf '[charm]\nname=Charm\nbaseurl=https://repo.charm.sh/yum/\nenabled=1\ngpgcheck=1\ngpgkey=https://repo.charm.sh/yum/gpg.key\n' \
            | sudo tee /etc/yum.repos.d/charm.repo
        sudo dnf install -y gum
    else echo "Cannot install gum automatically."; exit 1; fi
fi

if   command -v sudo &>/dev/null; then ESC="sudo"
elif command -v doas &>/dev/null; then ESC="doas"
else gum style --foreground "$C_ERR" "sudo or doas required."; exit 1; fi

if   command -v pacman &>/dev/null; then PM="pacman"
elif command -v apt    &>/dev/null; then PM="apt"
elif command -v dnf    &>/dev/null; then PM="dnf"
else gum style --foreground "$C_ERR" "No supported package manager."; exit 1; fi

[ -z "$SHELL" ] && gum style --foreground "$C_ERR" "SHELL not set." && exit 1

ok()      { gum style --foreground "$C_OK"   " ✔  $*"; }
err()     { gum style --foreground "$C_ERR"  " ✖  $*"; }
warn()    { gum style --foreground "$C_WARN" " ⚠  $*"; }
info()    { gum style --foreground "$C_INFO" " ·  $*"; }
confirm() { gum confirm --prompt.foreground="$C_WARN" "$1"; }

rand_spinner() { echo "${SPINNERS[$(( RANDOM % ${#SPINNERS[@]} ))]}"; }

spin() {
    local title="$1"; shift
    gum spin --spinner "$(rand_spinner)" --title "$title" -- "$@"
}

pkg_installed() {
    case "$PM" in
        pacman) pacman -Q "$1" &>/dev/null ;;
        apt)    dpkg -s "$1" &>/dev/null 2>&1 ;;
        dnf)    rpm -q "$1" &>/dev/null ;;
    esac
}

pkg_label() {
    if pkg_installed "$1"; then gum style --foreground "$C_OK"  "[installed]"
    else                        gum style --foreground "$C_DIM" "[not installed]"; fi
}

_ensure_sudo() {
    if [ "$ESC" = "sudo" ] && ! sudo -n true 2>/dev/null; then
        echo
        gum style --foreground "$C_WARN" " ⚠  sudo password required"
        sudo -v
        echo
    fi
}

do_install() {
    local pkg="$1"
    if pkg_installed "$pkg"; then
        warn "$pkg — already installed, skipping"
        return
    fi
    _ensure_sudo
    case "$PM" in
        pacman) $ESC pacman -S --needed --noconfirm "$pkg" ;;
        apt)    $ESC apt install -y "$pkg" ;;
        dnf)    $ESC dnf install -y "$pkg" ;;
    esac
    local rc=$?
    [ $rc -ne 0 ] && err "$pkg installation failed"
    return $rc
}

do_remove() {
    local pkg="$1"
    if ! pkg_installed "$pkg"; then
        warn "$pkg — not installed"
        return
    fi
    _ensure_sudo
    case "$PM" in
        pacman)
            if [ "$pkg" = "libvirt" ]; then
                $ESC pacman -Rddn --noconfirm "$pkg"
            else
                $ESC pacman -Rns --noconfirm "$pkg"
            fi
            ;;
        apt)    $ESC apt remove -y "$pkg" ;;
        dnf)    $ESC dnf remove -y "$pkg" ;;
    esac
    local rc=$?
    [ $rc -ne 0 ] && err "$pkg removal failed"
    return $rc
}

svc_stop_disable() {
    local svc="$1"
    systemctl is-active  --quiet "$svc" 2>/dev/null \
        && { $ESC systemctl stop    "$svc"; ok "Stopped $svc"; }
    systemctl is-enabled --quiet "$svc" 2>/dev/null \
        && { $ESC systemctl disable "$svc"; ok "Disabled $svc"; }
}

svc_enable() {
    spin "Enabling $1..." $ESC systemctl enable --now "$1"
    ok "$1 enabled"
}

show_banner() {
    clear
    gum style \
        --foreground "$C_TITLE" --border double --border-foreground "$C_TITLE" \
        --align center --width 54 --padding "1 4" \
        "QEMU Virtualization · N1R4" \
        "$(gum style --foreground "$C_DIM" "QEMU · KVM · Libvirt · Virt-Manager")"
    echo
    }

check_virt() {
    gum style --foreground "$C_TITLE" --bold "  Virtualisation Check"
    echo
    if   grep -qE 'vmx' /proc/cpuinfo 2>/dev/null; then ok "Intel VT-x detected"
    elif grep -qE 'svm' /proc/cpuinfo 2>/dev/null; then ok "AMD-V (SVM) detected"
    else
        err "No vmx/svm flags in /proc/cpuinfo"
        gum style --foreground "$C_WARN" --border rounded --border-foreground "$C_WARN" \
            --padding "0 2" --width 50 \
            "Enable CPU virtualisation in BIOS/UEFI:" \
            "  Intel: VT-x / Virtualisation Technology" \
            "  AMD:   AMD-V / SVM Mode" \
            "  Ref:   https://wiki.archlinux.org/title/KVM"
    fi
    dmesg 2>/dev/null | grep -qiE 'DMAR|IOMMU' \
        && ok "IOMMU active" \
        || warn "IOMMU not detected — GPU passthrough unavailable"
    [ -e /dev/kvm ] && ok "/dev/kvm present" || warn "/dev/kvm not found"
    echo
}

add_kvm_group() {
    [ ! -e /dev/kvm ] && warn "Skipping kvm group — /dev/kvm not found" && return
    sudo usermod "$USER" -aG kvm
    ok "$USER → kvm (re-login required)"
}

do_qemu_desktop() {
    if [ "$1" = "install" ]; then do_install "qemu-desktop"; add_kvm_group
    else do_remove "qemu-desktop"; fi
}

do_qemu_emulators() {
    if [ "$1" = "install" ]; then
        do_install "qemu-emulators-full"; do_install "swtpm"
    else
        do_remove "swtpm"; do_remove "qemu-emulators-full"
    fi
}

do_virt_manager() {
    if [ "$1" = "install" ]; then do_install "virt-manager"
    else                          do_remove  "virt-manager"; fi
}

setup_libvirt() {
    if [ "$PM" = "pacman" ] && pacman -Q iptables 2>/dev/null | grep -q '^iptables '; then
        warn "legacy iptables conflicts with iptables-nft"
        confirm "Remove legacy iptables?" && do_remove "iptables" || warn "Skipped — networking may break"
    fi
    do_install "dnsmasq"
    do_install "iptables-nft"
    spin "Setting firewall backend..." $ESC sed -i \
        's/^#\?firewall_backend *= *".*"/firewall_backend = "iptables"/' \
        /etc/libvirt/network.conf
    ok "firewall_backend = iptables"
    if systemctl is-active --quiet polkit 2>/dev/null; then
        spin "Configuring polkit auth..." bash -c "
            $ESC sed -i 's/^#\?auth_unix_ro *= *\".*\"/auth_unix_ro = \"polkit\"/' /etc/libvirt/libvirtd.conf
            $ESC sed -i 's/^#\?auth_unix_rw *= *\".*\"/auth_unix_rw = \"polkit\"/' /etc/libvirt/libvirtd.conf"
        ok "polkit auth configured"
    else warn "polkit not running — skipping"; fi
    spin "Adding $USER to libvirt group..." $ESC usermod "$USER" -aG libvirt
    ok "$USER → libvirt (re-login required)"
    spin "Updating nsswitch.conf..." bash -c \
        "for v in libvirt libvirt_guest; do
             grep -wq \"\$v\" /etc/nsswitch.conf || $ESC sed -i \"/^hosts:/ s/\$/ \$v/\" /etc/nsswitch.conf
         done"
    ok "nsswitch.conf updated"
    svc_enable "libvirtd.service"
    spin "Setting default net autostart..." $ESC virsh net-autostart default
    ok "Default libvirt network → autostart"
    add_kvm_group
}

do_libvirt() {
    if [ "$1" = "install" ]; then
        do_install "libvirt"; do_install "dmidecode"; setup_libvirt
    else
        svc_stop_disable "libvirtd.service"
        do_remove "libvirt"; do_remove "dmidecode"
    fi
}

main() {
    show_banner
    check_virt

    while true; do
        local q_l e_l l_l v_l
        q_l=$(pkg_label "qemu-desktop")
        e_l=$(pkg_label "qemu-emulators-full")
        l_l=$(pkg_label "libvirt")
        v_l=$(pkg_label "virt-manager")

        local choice
        choice=$(gum choose \
            --header "$(gum style --foreground "$C_DIM" " ↑↓ move · Enter select")" \
            --cursor.foreground="$C_TITLE" \
            "  Install all" \
            "  QEMU Desktop          $q_l" \
            "  QEMU Emulators        $e_l" \
            "󱒃  Libvirt               $l_l" \
            "󰹑  Virt-Manager          $v_l" \
            "󰆴  Remove packages" \
            "󰈆  Exit")

        [ -z "$choice" ] && break
        echo

        case "$choice" in
            *"QEMU Desktop"*)
                if pkg_installed "qemu-desktop"; then
                    confirm "qemu-desktop installed. Remove?" \
                        && do_qemu_desktop remove || info "Cancelled"
                else
                    confirm "Install QEMU Desktop?" \
                        && do_qemu_desktop install || info "Cancelled"
                fi ;;

            *"QEMU Emulators"*)
                if pkg_installed "qemu-emulators-full"; then
                    confirm "qemu-emulators-full installed. Remove?" \
                        && do_qemu_emulators remove || info "Cancelled"
                else
                    confirm "Install QEMU Emulators + swtpm?" \
                        && do_qemu_emulators install || info "Cancelled"
                fi ;;

            *"Libvirt"*)
                if pkg_installed "libvirt"; then
                    confirm "libvirt installed. Stop service and remove?" \
                        && do_libvirt remove || info "Cancelled"
                else
                    confirm "Install Libvirt + dmidecode?" \
                        && do_libvirt install || info "Cancelled"
                fi ;;

            *"Virt-Manager"*)
                if pkg_installed "virt-manager"; then
                    confirm "virt-manager installed. Remove?" \
                        && do_virt_manager remove || info "Cancelled"
                else
                    confirm "Install Virt-Manager?" \
                        && do_virt_manager install || info "Cancelled"
                fi ;;

            *"Install all"*)
                confirm "Install full stack?" || { info "Cancelled"; continue; }
                do_qemu_desktop install
                do_qemu_emulators install
                do_libvirt install
                do_virt_manager install ;;

            *"Remove packages"*)
                local removable=()
                pkg_installed "qemu-desktop"        && removable+=("qemu-desktop")
                pkg_installed "qemu-emulators-full" && removable+=("qemu-emulators-full")
                pkg_installed "swtpm"               && removable+=("swtpm")
                pkg_installed "libvirt"             && removable+=("libvirt")
                pkg_installed "dmidecode"           && removable+=("dmidecode")
                pkg_installed "virt-manager"        && removable+=("virt-manager")
                pkg_installed "dnsmasq"             && removable+=("dnsmasq")

                if [ ${#removable[@]} -eq 0 ]; then
                    warn "No managed packages installed"
                    continue
                fi

                local to_remove
                to_remove=$(printf '%s\n' "${removable[@]}" | gum choose --no-limit \
                    --header "$(gum style --foreground "$C_DIM" " Space multi-select · Enter confirm")" \
                    --cursor.foreground="$C_ERR")

                [ -z "$to_remove" ] && info "Nothing selected" && continue
                confirm "Remove selected?" || { info "Cancelled"; continue; }

                while IFS= read -r pkg; do
                    [ -z "$pkg" ] && continue
                    [ "$pkg" = "libvirt" ] && svc_stop_disable "libvirtd.service"
                    do_remove "$pkg"
                done <<< "$to_remove" ;;

            *"Exit"*)
                echo; ok "Done — re-login if group changes were made."
                break ;;
        esac
        echo
    done
}

main
