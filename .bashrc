# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

export PATH=$HOME/.cabal/bin:$PATH:$HOME/bin:$HOME/.scripts:/$HOME/.scripts/gsd:$HOME/apps/android/android-sdk-linux_86/tools:/usr/local/sphinx/bin/:$HOME/node_modules/.bin:$HOME/Dropbox/private/scripts/
ECLIPSE_HOME=$HOME/apps/eclipse
FRIENDLY_HOSTNAME='0'
set expand-tilde off
MAIL=/var/spool/mail/minhajuddin && export MAIL
#export PROMPT_COMMAND='history -n; history -a;'
# If not running interactively, don't do anything
if [[ ! -z "$PS1" ]] ; then

  export EDITOR=vi
  #custom configuration
  . $HOME/.scripts/bash_functions.bash
  . $HOME/.bash_completion

  # don't put duplicate lines in the history. See bash(1) for more options
  # ... or force ignoredups and ignorespace
  HISTCONTROL=ignoreboth

  # append to the history file, don't overwrite it
  shopt -s histappend

  # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
  HISTSIZE=10000
  HISTFILESIZE=10000
  HISTTIMEFORMAT="%F %T "
  HISTIGNORE=" *:rm -f*:rm -r*:*--force*" # history:awesome-ignored

  # check the window size after each command and, if necessary,
  # update the values of LINES and COLUMNS.
  shopt -s checkwinsize

  # make less more friendly for non-text input files, see lesspipe(1)
  [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

  # set variable identifying the chroot you work in (used in the prompt below)
  if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
  fi

  # set a fancy prompt (non-color, unless we know we "want" color)
  case "$TERM" in
    xterm-color) color_prompt=yes;;
  esac

  #aliases to cd into the core dirs
  PROJECT_PARENT_DIRS[0]="$HOME/repos/core"

  for PARENT_DIR in ${PROJECT_PARENT_DIRS[@]} ; do
    if [ -d "$PARENT_DIR" ]; then
      for PROJECT_DIR in $(/bin/ls $PARENT_DIR); do
        if [ ! -z `which $PROJECT_DIR` ]; then
          continue # don't set alias if there is something already a command on the path with the same name
        fi
        if [ -d "$PARENT_DIR/$PROJECT_DIR" ]; then
          alias "$PROJECT_DIR"="cd $PARENT_DIR/$PROJECT_DIR"
        fi
      done
    fi
  done
  #end alias

  # uncomment for a colored prompt, if the terminal has the capability; turned
  # off by default to not distract the user: the focus in a terminal window
  # should be on the output of commands, not on the prompt
  #force_color_prompt=yes

  if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
      # We have color support; assume it's compliant with Ecma-48
      # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
      # a case would tend to support setf rather than setaf.)
      color_prompt=yes
    else
      color_prompt=
    fi
  fi

  if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
  else
    PS1="\[\033[1;33m\]\W\[\033[00m\] \[\033[0;36m\]\$\[\033[00m\] "
    #PS1="\[\033[1;31m\]\h\[\033[00m\] \[\033[1;33m\]\W\[\033[00m\] \[\033[0;36m\]\$\[\033[00m\] "
  fi
  unset color_prompt force_color_prompt

  # If this is an xterm set the title to user@host:dir
  case "$TERM" in
    xterm*|rxvt*)
      PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
      ;;
    *)
      ;;
  esac

  # enable color support of ls and also add handy aliases
  if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
  fi

  # some more ls aliases
  alias ll='ls -alF'
  alias la='ls -A'
  alias l='ls -CF'

  # Add an "alert" alias for long running commands.  Use like so:
  #   sleep 10; alert
  alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


  # Alias definitions.
  # You may want to put all your additions into a separate file like
  # ~/.bash_aliases, instead of adding them here directly.
  # See /usr/share/doc/bash-doc/examples in the bash-doc package.

  if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
  fi

  # enable programmable completion features (you don't need to enable
  # this, if it's already enabled in /etc/bash.bashrc and /etc/profile
  # sources /etc/bash.bashrc).
  if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
  fi

  source ~/.bashrc_extensions

fi
#source rvm
[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

# Added by autojump install.sh
[ -f /usr/share/autojump/autojump.sh ] && source /usr/share/autojump/autojump.sh
source ~/.bashlocal.sh

export GOROOT=$HOME/go
export GOPATH=$HOME/gocode
PATH=$PATH:$HOME/go/bin:$HOME/.rvm/bin:$GOPATH/bin # Add RVM to PATH for scripting

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
## Say something wise
#fortune
