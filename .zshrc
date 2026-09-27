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

# zsh-completions
if [ -d ${HOME}/.zsh/zsh-completions/src ] ; then
   fpath=(${HOME}/.zsh/zsh-completions/src $fpath)
fi

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
compinit -u

PROMPT="%/%% "
PROMPT2="%_%% "
SPROMPT="%r is correct? [n,y,a,e]: "

## golang
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME

# common
export PATH=~/.local/bin:$PATH

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
alias dre="docker restart"
alias drm="docker rm"
alias dl="docker ps -l -q"
alias dstopall="docker stop `docker ps -aq`"
alias drmall="docker rm `docker ps -aq`"
alias dc="docker compose"

#aws
alias getlatestamazonlinux="aws ec2 describe-images --region us-west-2 --owners amazon --filters \"Name=name,Values=amzn-ami-hvm-*-gp2\" --query 'reverse(sort_by(Images,&CreationDate))[0].ImageId' --output text"
# awsenv [プロファイル名]
#   指定プロファイルの認証情報を環境変数に展開する。省略時は既定プロファイル
#   （AWSENV_DEFAULT_PROFILE で変更可）。ロールを assume するプロファイルでも、
#   別アカウントのプロファイルでも同じように使える。
#
#   認証は env に展開した一時クレデンシャルだけで行い、shared config のプロファイルは
#   使わせない。そのため AWS_PROFILE には role_arn も認証情報も持たない中継用プロファイル
#   （既定: awsenv、AWSENV_SHIM_PROFILE で変更可）を固定で指す。role_arn 付きを指すと
#   ecsk 等が env を無視して自前で AssumeRole し直し、未設定だと default に、
#   root（login）だと人の身元にフォールバックする。中継用プロファイルは認証情報を
#   持たないので、一時クレデンシャルが失効すれば CLI も ecsk も fail closed する。
#
#   展開元のプロファイル名は AWSENV_PROFILE に入れる（表示用。AWS の解決には使わない）。
awsenv() {
  local profile="${1:-${AWSENV_DEFAULT_PROFILE:-login}}"

  if ! aws configure list-profiles 2>/dev/null | grep -qx -- "$profile"; then
    echo "awsenv: プロファイル '$profile' が ~/.aws/config にありません" >&2
    return 1
  fi

  # source_profile を辿って role_arn を持たないプロファイル（＝ログイン元）を探す
  local root="$profile" next hops=0
  while [ -n "$(aws configure get role_arn --profile "$root" 2>/dev/null)" ]; do
    next="$(aws configure get source_profile --profile "$root" 2>/dev/null)"
    if [ -z "$next" ] || [ "$next" = "$root" ] || [ "$hops" -ge 8 ]; then
      break
    fi
    root="$next"
    hops=$((hops + 1))
  done

  if [ -n "$(aws configure get role_arn --profile "$root" 2>/dev/null)" ]; then
    echo "awsenv: '$profile' の source_profile を辿れませんでした（root=$root）。~/.aws/config を確認してください" >&2
    return 1
  fi

  local creds
  if ! creds="$(aws --profile "$profile" configure export-credentials --format env 2>&1)"; then
    echo "awsenv: '$profile' の認証情報を取得できません。まず 'aws login --profile $root' を実行してください" >&2
    echo "  $creds" >&2
    return 1
  fi

  unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN \
        AWS_CREDENTIAL_EXPIRATION AWS_PROFILE AWS_REGION AWS_DEFAULT_REGION
  eval "$creds"

  # 存在しない名前を指すと AWS CLI がエラーになるので、無ければ設定しない。
  local shim="${AWSENV_SHIM_PROFILE:-awsenv}"
  if aws configure list-profiles 2>/dev/null | grep -qx -- "$shim"; then
    export AWS_PROFILE="$shim"
  else
    echo "awsenv: 中継用プロファイル '$shim' がありません。作成してください:" >&2
    echo "  aws configure set region ap-northeast-1 --profile $shim" >&2
  fi

  # 展開元のプロファイル名。starship の [custom.awsenv] が読む。
  export AWSENV_PROFILE="$profile"

  local region
  region="$(aws configure get region --profile "$profile" 2>/dev/null)"
  if [ -n "$region" ]; then
    export AWS_REGION="$region" AWS_DEFAULT_REGION="$region"
  fi

  echo "awsenv: $profile (root=$root, region=${AWS_REGION:-未設定}, 失効 ${AWS_CREDENTIAL_EXPIRATION:-なし}, AWS_PROFILE=${AWS_PROFILE:-未設定})"
}

# ghq & peco
bindkey '^\' peco-src
function peco-src() {
  local src=$(ghq list --full-path | peco --query "$LBUFFER")
  if [ -n "$src" ]; then
	  BUFFER="cd $src"
	  zle accept-line
  fi
  zle -R -c
}

function zd() {
  local dir
  dir=$(zoxide query -l | peco) && cd "$dir"
}


zle -N peco-src

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
eval "$(mise activate zsh)"
eval "$(direnv hook zsh)"
eval "$(zoxide init zsh --cmd cd)"
eval "$(starship init zsh)"
if [[ -z "$TMUX" && -z "$ZELLIJ" ]] && [[ "$TERM_PROGRAM" == "ghostty" || -n "$GHOSTTY_BIN" ]]; then
  exec zellij
fi
