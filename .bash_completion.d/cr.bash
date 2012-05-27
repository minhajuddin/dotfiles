#!/bin/sh
# rake bash completion script

__complete_cr_command() {
  cat <(ls ~/repos) <(ls ~/core) <(ls ~/core/omar) <(ls ~/os) | grep "^$2"
}

complete -C __complete_cr_command -o default cr
