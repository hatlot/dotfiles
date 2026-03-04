#!/bin/bash

# エラーでスクリプトを終了する
set -e

echo "dotfilesのインストールを開始..."

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

elif command -v apt &> /dev/null; then

    sudo apt update
    if [ -f "$HOME/dotfiles/Debian/packages.txt" ]; then
        echo "aptでパッケージをインストール..."
        xargs -a "$HOME/dotfiles/Debian/packages.txt" sudo apt install -y
    fi

    if ! command -v starship &> /dev/null; then
        echo "starshipをインストール..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

else
    echo "対応していないパッケージマネージャーです。pacmanまたはaptを使用してください。"
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

ln -sfv "$HOME/dotfiles/.config/starship.toml" "$HOME/.config/starship.toml"

echo "Dotfiles installation complete!"
