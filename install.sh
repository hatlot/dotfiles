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

if ! ask_confirm "インストール処理を開始してもよろしいですか？"; then
    log "キャンセルされました。スクリプトを終了します。"
    exit 0
fi

STARSHIP_SRC=""

if ask_confirm "パッケージのインストールを開始してもよろしいですか？"; then

    # 必要なパッケージをインストール
    if command -v pacman &> /dev/null; then
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

    if [ -f "$HOME/dotfiles/archlinux/packages.txt" ]; then
        log "Installing packages with yay..."
        yay -S --needed - < "$HOME/dotfiles/archlinux/packages.txt"
    fi
    STARSHIP_SRC="$HOME/dotfiles/config/starship/starship_arch.toml"

    elif command -v apt &> /dev/null; then
    log "Updating package list..."
    sudo apt update
    source /etc/os-release
    if [[ "$ID" == "debian" || "$ID" == "ubuntu" ]]; then
        if [ -f "$HOME/dotfiles/$ID/packages.txt" ]; then
            log "Installing packages with apt..."
            xargs -a "$HOME/dotfiles/$ID/packages.txt" sudo apt install -y
        fi

        if ! command -v starship &> /dev/null; then
            log "Installing starship..."
            curl -sS https://starship.rs/install.sh | sh -s -- -y
        fi
        STARSHIP_SRC="$HOME/dotfiles/config/starship/starship_$ID.toml"
    fi
    
    elif command -v dnf &> /dev/null; then
    sudo dnf check-update || true
    sudo dnf install epel-release -y
    if [ -f "$HOME/dotfiles/almalinux/packages.txt" ]; then
        log "Installing packages with dnf..."
        xargs -a "$HOME/dotfiles/almalinux/packages.txt" sudo dnf install -y
    fi

    if ! command -v starship &> /dev/null; then
        log "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
    STARSHIP_SRC="$HOME/dotfiles/config/starship/starship_alma.toml"

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

    else
    error "Unsupported package manager."
    fi

else
    log "パッケージのインストールはスキップされました。"
fi

if ask_confirm "シンボリックの処理を開始してもよろしいですか？"; then

    # Creating symbolic links for dotfiles
    log "Creating dotfiles symbolic links..."
    mkdir -p "$HOME/.config"
    DOT_FILES=(
        .bashrc
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
    log "シンボリックの処理はスキップされました。"
fi

log "Dotfiles installation complete!"
