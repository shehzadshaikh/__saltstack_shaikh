{%- from "linux/map.jinja" import system with context %}

# History across sessions for Bash
if [ -n "$BASH_VERSION" ]; then
  # Avoid duplicates
  export HISTCONTROL=ignoredups:erasedups

  # When the shell exits, append to the history file instead of overwriting it
  export HISTTIMEFORMAT="|%Y%m%d|%T|%Z|"   # It will keep the history compact
  export HISTSIZE=100000                   # big history
  export HISTFILESIZE=100000               # big history
  shopt -s histappend                      # append to history, don't overwrite it

  # After each command, append to the history file and reread it
  export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r; $PROMPT_COMMAND"
fi
