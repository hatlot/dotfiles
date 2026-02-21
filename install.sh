#!/bin/bash

# エラーでスクリプトを終了する
set -e

echo "Installing dotfiles..."

# 必要なパッケージをインストール
echo "Updating package list and installing packages from pkglist.txt..."
sudo pacman -Syu --needed - < pkglist.txt

mkdir -p "$HOME/.config"

# シンボリックリンクの作成
echo "Creating symbolic links for dotfiles..."
DOT_FILES=(
    .bashrc
    .zshrc
)
for file in "${DOT_FILES[@]}"; do
    ln -sfv "$HOME/dotfiles/$file" "$HOME/$file"
done

ln -sfv "$HOME/dotfiles/.config/starship.toml" "$HOME/.config/starship.toml"

echo "Dotfiles installation complete!"
