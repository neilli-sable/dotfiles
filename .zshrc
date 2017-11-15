# Created by newuser for 5.0.0
export EDITOR=vim
export LANG=ja_JP.UTF-8
export KCODE=u
export AUTOFEATURE=true

bindkey -e #emacs mode

setopt no_beep
setopt auto_cd
setopt correct
setopt magic_equal_subst

## ヒストリを保存するファイル
HISTFILE=~/.zsh_history
## メモリ上のヒストリ数。
## 大きな数を指定してすべてのヒストリを保存するようにしている。
HISTSIZE=10000000
## 保存するヒストリ数
SAVEHIST=$HISTSIZE
## ヒストリファイルにコマンドラインだけではなく実行時刻と実行時間も保存する。
setopt extended_history
## 同じコマンドラインを連続で実行した場合はヒストリに登録しない。
setopt hist_ignore_dups
## スペースで始まるコマンドラインはヒストリに追加しない。
setopt hist_ignore_space
## すぐにヒストリファイルに追記する。
setopt inc_append_history
## zshプロセス間でヒストリを共有する。
setopt share_history
## C-sでのヒストリ検索が潰されてしまうため、出力停止・開始用にC-s/C-qを使わない。
setopt no_flow_control

## 初期化
autoload -U compinit
compinit

PROMPT="%/%% "
PROMPT2="%_%% "
SPROMPT="%r is correct? [n,y,a,e]: "

## Tomcatの環境変数
export CATALINA_HOME=/usr/share/tomcat7
export CATALINA_BASE=/home/seiya/www/tomcat7

##anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

## golang
export GOPATH=$HOME
export PATH="$HOME/.go/bin:$PATH"

## rust
source $HOME/.cargo/env

# zsh-completions
if [ -d ${HOME}/.zsh/zsh-completions/src ] ; then
   fpath=(${HOME}/.zsh/zsh-completions/src $fpath)
   #compinit
fi

## Show git repos status
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd () { vcs_info }
RPROMPT='${vcs_info_msg_0_}'

## Alias
alias gst="git status"
alias gsl="git stash list"
alias gl="git log"
alias gln="git log --pretty=short --name-status"
alias gls="git log --oneline"
alias glp="git log -p"
alias ga='git add'
alias gap="git add -p"
alias gaa='git add .'
alias gaaa='git add -A'
alias gb="git branch -a"
alias gbd='git branch -d '
alias gd='git diff'
alias gc='git commit'
alias gca='git commit -a'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcom='git checkout master'
alias dps="docker ps"
alias dpsa="docker ps -a"
alias dstart="docker start"
alias dstop="docker stop"
alias drm="docker rm"
alias dl="docker ps -l -q"
alias dstopall="docker stop `docker ps -aq`"
alias drmall="docker rm `docker ps -aq`"
alias rspec='rspec -c'

case "${OSTYPE}" in
darwin*)
  alias ls="ls -laG"
  ;;
linux*)
  alias ls='ls -la --color'
  ;;
esac

alias vi='vim'

alias tarC='tar zcvf'
alias tarM='tar zxvf'

if [[ -n "$PS1" ]]; then
  cd() {
    histf=$HOME/.zsh_history
    if [ $# -eq 1 ]; then
      builtin cd $1
      if [ $? -ne 0 ] ; then
        return 1
      fi
      echo "cd" $PWD >> $histf
      fc -R
    else
      builtin cd $*
    fi
  }
fi

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
case "${OSTYPE}" in
linux*)
  eval "$(dircolors -b)"
  ;;
esac
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
export PATH="$HOME/bin:$PATH"
export PATH=$PATH:$HOME/Library/Android/sdk/platform-tools
export PATH=$PATH:$HOME/.composer/vendor/bin
eval "$(direnv hook zsh)"
