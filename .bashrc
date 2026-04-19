#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
alias la='ls -a'
alias ll='ls -la'
export LANG=ja_JP.UTF-8

if [ -f /etc/arch-release ]; then
    source ~/dotfiles/Arch/.aliases_arch
elif [ -f /etc/debian_version ]; then
    source ~/dotfiles/Debian/.aliases_debian
elif [ -f /etc/ubuntu_advantage ]; then
    source ~/dotfiles/Ubuntu/.aliases_ubuntu
elif [ -f /etc/redhat-release ]; then
    source ~/dotfiles/AlmaLinux/.aliases_alma
fi

[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
