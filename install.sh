#!/bin/bash

# エラーでスクリプトを終了する
set -e

echo "dotfilesのインストールを開始..."

STARSHIP_SRC=""

# 必要なパッケージをインストール
if command -v pacman &> /dev/null; then
    echo "pacmanを使用してパッケージをインストール..."
    if ! command -v yay &> /dev/null; then
        sudo pacman -S --needed --noconfirm git base-devel
        echo "yayをインストール..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
        rm -rf /tmp/yay
        echo "yayのインストールが完了しました。"
    fi

    if [ -f "$HOME/dotfiles/Arch/packages.txt" ]; then
        echo "yayでパッケージをインストール..."
        yay -S --needed - < "$HOME/dotfiles/Arch/packages.txt"
    fi
    STARSHIP_SRC="$HOME/dotfiles/.config/starship_arch.toml"

elif command -v apt &> /dev/null; then

    sudo apt update
    . /etc/os-release
    if [[ "$ID" == "debian" ]]; then
        if [ -f "$HOME/dotfiles/Debian/packages.txt" ]; then
        echo "aptでパッケージをインストール..."
        xargs -a "$HOME/dotfiles/Debian/packages.txt" sudo apt install -y
        fi

        if ! command -v starship &> /dev/null; then
            echo "starshipをインストール..."
            curl -sS https://starship.rs/install.sh | sh -s -- -y
        fi
        STARSHIP_SRC="$HOME/dotfiles/.config/starship_debian.toml"
    fi
    if [[ "$ID" == "ubuntu" ]]; then
        if [ -f "$HOME/dotfiles/Ubuntu/packages.txt" ]; then
        echo "aptでパッケージをインストール..."
        xargs -a "$HOME/dotfiles/Ubuntu/packages.txt" sudo apt install -y
        fi

        if ! command -v starship &> /dev/null; then
            echo "starshipをインストール..."
            curl -sS https://starship.rs/install.sh | sh -s -- -y
        fi
        STARSHIP_SRC="$HOME/dotfiles/.config/starship_ubuntu.toml"
    fi
    
elif command -v dnf &> /dev/null; then

    sudo dnf check-update || true
    sudo dnf install epel-release -y
    if [ -f "$HOME/dotfiles/AlmaLinux/packages.txt" ]; then
        echo "dnfでパッケージをインストール..."
        xargs -a "$HOME/dotfiles/AlmaLinux/packages.txt" sudo dnf install -y
    fi

    if ! command -v starship &> /dev/null; then
        echo "starshipをインストール..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
    STARSHIP_SRC="$HOME/dotfiles/.config/starship_alma.toml"

    # Zshプラグインのインストール
    echo "Installing Zsh plugins..."
    ZSH_PLUGIN_DIR="$HOME/.zsh"
    mkdir -p "$ZSH_PLUGIN_DIR"

    if [ ! -d "$ZSH_PLUGIN_DIR/zsh-autosuggestions" ]; then
        echo "zsh-autosuggestionsをクローンしています..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGIN_DIR/zsh-autosuggestions"
    fi

    if [ ! -d "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting" ]; then
        echo "zsh-syntax-highlightingをクローンしています..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
    fi

else
    echo "対応していないパッケージマネージャーです。"
    exit 1
fi


# シンボリックリンクの作成
echo "Creating symbolic links for dotfiles..."
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
    echo "$STARSHIP_SRCが見つかりませんでした。"
fi

echo "Dotfiles installation complete!"