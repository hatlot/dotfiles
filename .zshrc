# Created by newuser for 5.9

# 日本語環境の設定
export LANG=ja_JP.UTF-8

# 色を有効にする
autoload -Uz colors && colors

# 補完機能を有効化
autoload -Uz compinit
compinit

# 補完候補を矢印キーで選択できるようにする
zstyle ':completion:*' menu select
# 補完候補に色をつける
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# 大文字・小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ヒストリー (履歴) 設定
HISTFILE=~/.zsh_history   # 履歴ファイルの場所
HISTSIZE=10000            # メモリに保存する履歴数
SAVEHIST=10000            # ファイルに保存する履歴数
setopt share_history      # 複数のターミナルで履歴を共有
setopt hist_ignore_dups   # 直前と同じコマンドは記録しない
setopt hist_ignore_all_dups # 重複する古い履歴を削除

# プラグインの読み込み
# シンタックスハイライト (コマンドの色付け)
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
# Arch Linuxの場合
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Debian/Ubuntuの場合
elif [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# オートサジェスト (入力予測)
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
# Arch Linuxの場合
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# Debian/Ubuntuの場合
elif [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
# 予測文字の色を少し見やすくする
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'

# エイリアス
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias la='ls -a'
alias ll='ls -la'

if [ -f /etc/arch-release ]; then
    source ~/dotfiles/Arch/.aliases_arch
elif [ -f /etc/debian_version ]; then
    source ~/dotfiles/Debian/.aliases_debian
fi

# Starshipの起動 (プロンプトの見た目)
eval "$(starship init zsh)"
