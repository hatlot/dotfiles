# Created by newuser for 5.9

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
# killコマンドの補完を有効化
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

setopt auto_cd            # ディレクトリ名だけでcdする
setopt interactive_comments  # コマンドの途中にコメントを入れられるようにする

# ヒストリー (履歴) 設定
HISTFILE=~/.zsh_history   # 履歴ファイルの場所
HISTSIZE=10000            # メモリに保存する履歴数
SAVEHIST=10000            # ファイルに保存する履歴数
setopt share_history      # 複数のターミナルで履歴を共有
setopt hist_ignore_dups   # 直前と同じコマンドは記録しない
setopt hist_ignore_all_dups # 重複する古い履歴を削除
setopt hist_ignore_space  # 空白で始まるコマンドは履歴に残さない

# オートサジェスト (入力予測)
# Arch Linuxの場合
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# Debian/Ubuntuの場合
elif [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# その他の環境の場合 (ユーザーローカルにインストールしている場合など)
elif [ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# 予測文字の色を少し見やすくする
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'

# エイリアス
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias la='ls -a'
alias ll='ls -la'

if [ -f /etc/os-release ]; then
    source /etc/os-release
    if [ -f "$HOME/dotfiles/$ID/.aliases" ]; then
        source "$HOME/dotfiles/$ID/.aliases"
    fi
fi

# Starshipの起動 (プロンプトの見た目)
eval "$(starship init zsh)"

# シンタックスハイライト (コマンドの色付け)
# Arch Linuxの場合
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Debian/Ubuntuの場合
elif [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# その他の環境の場合 (ユーザーローカルにインストールしている場合など)
elif [ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ローカルの設定ファイルがあれば読み込む
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
