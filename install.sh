#!/bin/bash

# エラーでスクリプトを終了する
set -euo pipefail

log() {
    echo "[INFO] $*"
}
warn() {
    echo "[WARN] $*"
}
error() {
    echo "[ERROR] $*" >&2
    exit 1
}

if [[ $EUID -eq 0 ]]; then
    error "このスクリプトはrootユーザーで実行しないでください。"
fi

log "dotfilesのインストールを開始..."

STARSHIP_SRC=""

# 必要なパッケージをインストール
if command -v pacman &> /dev/null; then
    log "pacmanを使用してパッケージをインストール..."

    if ! command -v yay &> /dev/null; then
        sudo pacman -S --needed --noconfirm git base-devel

        log "yayをインストール..."
        TEMP_DIR=$(mktemp -d)
        trap '[[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"' EXIT

        git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"
        (cd "$TEMP_DIR/yay" && makepkg -si --noconfirm)
        log "yayのインストールが完了しました。"
    fi

    if [ -f "$HOME/dotfiles/archlinux/packages.txt" ]; then
        log "yayでパッケージをインストール..."
        yay -S --needed - < "$HOME/dotfiles/archlinux/packages.txt"
    fi
    STARSHIP_SRC="$HOME/dotfiles/.config/starship_arch.toml"

elif command -v apt &> /dev/null; then
    log "aptを使用してパッケージをインストール..."
    sudo apt update
    source /etc/os-release
    if [[ "$ID" == "debian" || "$ID" == "ubuntu" ]]; then
        if [ -f "$HOME/dotfiles/$ID/packages.txt" ]; then
            log "aptでパッケージをインストール..."
            xargs -a "$HOME/dotfiles/$ID/packages.txt" sudo apt install -y
        fi

        if ! command -v starship &> /dev/null; then
            log "starshipをインストール..."
            curl -sS https://starship.rs/install.sh | sh -s -- -y
        fi
        STARSHIP_SRC="$HOME/dotfiles/.config/starship_$ID.toml"
    fi
    
elif command -v dnf &> /dev/null; then
    log "dnfを使用してパッケージをインストール..."
    sudo dnf check-update || true
    sudo dnf install epel-release -y
    if [ -f "$HOME/dotfiles/almalinux/packages.txt" ]; then
        log "dnfでパッケージをインストール..."
        xargs -a "$HOME/dotfiles/almalinux/packages.txt" sudo dnf install -y
    fi

    if ! command -v starship &> /dev/null; then
        log "starshipをインストール..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
    STARSHIP_SRC="$HOME/dotfiles/.config/starship_alma.toml"

    # Zshプラグインのインストール
    log "Zshプラグインをインストール..."
    ZSH_PLUGIN_DIR="$HOME/.zsh"
    mkdir -p "$ZSH_PLUGIN_DIR"

    if [ ! -d "$ZSH_PLUGIN_DIR/zsh-autosuggestions" ]; then
        log "zsh-autosuggestionsをクローンしています..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGIN_DIR/zsh-autosuggestions"
    fi

    if [ ! -d "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting" ]; then
        log "zsh-syntax-highlightingをクローンしています..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
    fi

else
    error "対応していないパッケージマネージャーです。"
fi


# シンボリックリンクの作成
log "dotfilesのシンボリックリンクを作成..."
mkdir -p "$HOME/.config"
DOT_FILES=(
    .bashrc
    .zshrc
)
for file in "${DOT_FILES[@]}"; do
    ln -sfv "$HOME/dotfiles/$file" "$HOME/$file"
done

if [ -f "$STARSHIP_SRC" ]; then
    ln -sfv "$STARSHIP_SRC" "$HOME/.config/starship.toml"
else
    warn "$STARSHIP_SRCが見つかりませんでした。"
fi

log "Dotfiles installation complete!"