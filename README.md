# Dotfiles

## Features

- 堅牢なインストーラー: `set -euo pipefail` や `mktemp` を活用した、途中でエラーが発生しても環境を汚さない安全な設計。
- マルチOS対応: 実行環境のOSとパッケージマネージャー (`pacman/yay`, `apt`, `dnf`) を自動判別して適切な処理を行います。
- Starshipプロンプト: OSごとに専用のテーマ (`.toml`) を使用しています。

## Supported Environments

- Arch Linux
- Debian / Ubuntu
- AlmaLinux (RedHat系)
- Windows Subsystem for Linux (WSL)

## Installation

リポジトリをクローンし、セットアップスクリプトを実行するだけです。

```bash
# 1. リポジトリのクローン
git clone https://github.com/hatlot/dotfiles.git ~/dotfiles

# 2. ディレクトリへ移動
cd ~/dotfiles

# 3. インストールスクリプトの実行
./install.sh
```

## Post-Installation
デフォルトのシェルが Zsh でない場合は以下のコマンドを実行してターミナルを再起動してください。
```bash
chsh -s $(which zsh)
```
