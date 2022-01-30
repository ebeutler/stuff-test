# always open up tmux session 'main' if
# 1. tmux is available
# 2. we are in a interactive terminal
# 3. we aren't within screen
# 4. we aren't already within tmux
command -v tmux >/dev/null \
  && [ -n "$PS1" ] && [[ $- == *i* ]] \
  && [[ ! "$TERM" =~ screen ]] \
  && [[ ! "$TERM" =~ tmux ]] \
  && [ -z "$TMUX" ] \
  && exec tmux new-session -A -s main

[ "$TERM_PROGRAM" = tmux ] \
  && alias ssh='TERM=xterm-256color ssh'

[ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] \
  && command -v neofetch >/dev/null \
  && neofetch