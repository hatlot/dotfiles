#!/bin/bash

# Exit script on error
set -euo pipefail

log() {
    echo -e "\e[32m[INFO]\e[0m $*"
}

warn() {
    echo -e "\e[33m[WARN]\e[0m $*"
}

error() {
    echo -e "\e[31m[ERROR]\e[0m $*" >&2
    exit 1
}

ask_confirm() {
    read -r -p "$1 [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

if [[ $EUID -eq 0 ]]; then
    error "This script should not be run as root user."
fi

log "Starting dotfiles installation..."

if ! ask_confirm "Do you want to proceed with the installation?"; then
    log "Installation cancelled. Exiting script."
    exit 0
fi

if [ -f /etc/os-release ]; then
    source /etc/os-release
    OS_ID=${ID:-unknown}
else
    error "Cannot detect OS. /etc/os-release not found."
fi

log "Detected OS: $OS_ID"

PKG_LIST="$HOME/dotfiles/$OS_ID/packages.txt"
STARSHIP_SRC="$HOME/dotfiles/config/starship/starship_$OS_ID.toml"

case "$OS_ID" in
    arch|debian|ubuntu|almalinux)
        ;;
    *)
        error "Unsupported OS: $OS_ID"
        ;;
esac

if ask_confirm "Do you want to proceed with package installation?"; then
    case "$OS_ID" in
        arch)
            command -v pacman &> /dev/null || error "pacman is not installed"
            log "Installing packages using pacman..."
            if ! command -v yay &> /dev/null; then
                sudo pacman -S --needed --noconfirm git base-devel

                log "Installing yay..."
                TEMP_DIR=$(mktemp -d)
                trap '[[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]] && rm -rf -- "$TEMP_DIR"' EXIT

                git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"
                (cd "$TEMP_DIR/yay" && makepkg -si --noconfirm)
                log "Yay installation completed."
            fi

            if [ -f "$PKG_LIST" ]; then
                log "Installing packages with yay..."
                yay -S --needed - < "$PKG_LIST"
            fi
            ;;
        debian|ubuntu)
            command -v apt &> /dev/null || error "apt is not installed"
            log "Updating package list..."
            sudo apt update
            if [ -f "$PKG_LIST" ]; then
                log "Installing packages with apt..."
                xargs -a "$PKG_LIST" sudo apt install -y
            fi
            if ! command -v starship &> /dev/null; then
                log "Installing starship..."
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            fi
            ;;
        almalinux)
            command -v dnf &> /dev/null || error "dnf is not installed"
            log "Updating package list..."
            sudo dnf check-update || true
            sudo dnf install epel-release -y
            if [ -f "$PKG_LIST" ]; then
                log "Installing packages with dnf..."
                xargs -a "$PKG_LIST" sudo dnf install -y
            fi

            if ! command -v starship &> /dev/null; then
                log "Installing starship..."
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            fi

            # Installing Zsh plugins
            log "Installing Zsh plugins..."
            ZSH_PLUGIN_DIR="$HOME/.zsh"
            mkdir -p "$ZSH_PLUGIN_DIR"

            if [ ! -d "$ZSH_PLUGIN_DIR/zsh-autosuggestions" ]; then
                log "Cloning zsh-autosuggestions..."
                git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGIN_DIR/zsh-autosuggestions"
            fi

            if [ ! -d "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting" ]; then
                log "Cloning zsh-syntax-highlighting..."
                git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
            fi
            ;;
        *)
            error "Unsupported OS: $OS_ID"
            ;;
    esac
else
    log "Package installation skipped."
fi

if ask_confirm "Do you want to proceed with creating symbolic links?"; then

    # Creating symbolic links for dotfiles
    log "Creating dotfiles symbolic links..."
    mkdir -p "$HOME/.config"
    DOT_FILES=(
        .vimrc
        .zshrc
    )
    for file in "${DOT_FILES[@]}"; do
        ln -sfv "$HOME/dotfiles/$file" "$HOME/$file"
    done

    if [ -f "$STARSHIP_SRC" ]; then
        ln -sfv "$STARSHIP_SRC" "$HOME/.config/starship.toml"
    else
        warn "$STARSHIP_SRC not found."
    fi

else
    log "Creating symbolic links skipped."
fi

log "Dotfiles installation complete!"
