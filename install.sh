#!/bin/bash

# エラーでスクリプトを終了する
set -e

echo "dotfilesのインストールを開始..."

# 必要なパッケージをインストール
if command -v pacman &> /dev/null; then

    if [ -f "$HOME/dotfiles/Arch/packages.txt" ]; then
        echo "pacmanでパッケージをインストール..."
        sudo pacman -Syu --needed - < "$HOME/dotfiles/Arch/packages.txt"
    fi
    STARSHIP_SRC="$HOME/dotfiles/.config/starship_arch.toml"

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
    STARSHIP_SRC="$HOME/dotfiles/.config/starship_debian.toml"

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

if [ -f "$STARSHIP_SRC" ]; then
    ln -sfv "$STARSHIP_SRC" "$HOME/.config/starship.toml"
else
    echo "$STARSHIP_SRCが見つかりませんでした。"
fi

echo "Dotfiles installation complete!"
