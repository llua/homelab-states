# load wanted modules
for mod in 'pcre' 'net/tcp' 'complist'; do
  [[ -e $MODULE_PATH/zsh/$mod.so ]] && zmodload zsh/$mod
  unset mod
done

# Set/unset  shell options
# Globbing
setopt   ExtendedGlob  GlobAssign
# Misc
setopt   RcQuotes RecExact LongListJobs TransientRprompt MagicEqualSubst
# History 
setopt   ExtendedHistory HistIgnoreAllDups AppendHistory HistNoStore IncAppendHistory ShareHistory
# pushd settings
setopt   AutoPushd PushdMinus AutoCd PushdToHome PushdSilent PushdIgnoreDups
# Completion
setopt	 Zle AutoMenu
# Stuff we don't want
unsetopt BgNice AutoParamSlash Hup Correct CorrectAll MenuComplete AutoList Beep

# Set fpath
fpath=( ~/.config/functions(N) /usr/(local/)#share/zsh/($ZSH_VERSION/)#(site-)#functions/(*/)#(N/) )

# History & mail stuff
HISTFILE=~/(.config/)#.zsh_history(N[1])
HISTSIZE=15000
SAVEHIST=15000
MAILCHECK=1
mailpath+=( /var/spool/mail/${USER}(/N) ~/MailDir(/N) )

READNULLCMD=less

# colourssssssssssssssssssssssssssssssssssssss
autoload -Uz colors && colors
typeset -T ZLS_COLORS zls_colors
(( $+commands[dircolors] )) && eval $(dircolors -b)
ZLS_COLORS=${LS_COLORS//cd=40;33;01/cd=40;01;36} LS_COLORS=${ZLS_COLORS}

# Prompt stuff
PROMPT="(%{$fg[cyan]%}%m%{$reset_color%})%# "
RPROMPT="%B%{$fg[cyan]%}%~%{$reset_color%}%b"

# run-help's HELPDIR
HELPDIR=~/.cache/zsh-help(N)

# autoload my functions in .config/functions/ and zmv
autoload -Uz ${ZDOTDIR}/functions/**/[^_]*(N.:t) zmv edit-command-line 2>/dev/null

# Completion settings zshmodules(1)
# zstyle ':completion:function:completer:command:arguments:tag'

# separate man page completion by section.
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*:manuals'    separate-sections true 
# per-match descriptions (if available)
zstyle ':completion:*' verbose true
# descriptions of commands (if available)
zstyle ':completion:*' extra-verbose true
# if a description isn't defined, use the option's description (from -h|--help)
zstyle ':completion:*' auto-description 'specify: %d'
# default seperator between option -- description
zstyle ':completion:*' list-separator '::'
zstyle ':completion:*' completer _expand _complete _correct _approximate
# message telling you what you are completing
zstyle ':completion:*' format 'Completing %d'
# group completions by type
zstyle ':completion:*' group-name ''
# zstyle ':completion:*' menu select=long
# if there are atleast 0 matches, use menu selection (will always be true)
zstyle ':completion:*' menu select=0
# set colors for files/directories to be the same as ls(1)
zstyle ':completion:*:default' list-colors "$zls_colors[@]"
# everything else normal colors
zstyle ':completion:*' list-colors ''
# username completion
zstyle ':completion:*:(scp|ssh|rsync|telnet):*' users eric llua arx root
# hostname completion
zstyle ':completion:*:(scp|ssh|rsync|telnet):*' hosts umbra corbenik netslum login1 login2
# completion of pids owned by $USER
zstyle ':completion:*:(kill|strace):*' command 'ps -u $USER -o pid,cmd,tty'
# completion of process names 
zstyle ':completion:*:killall:*' command 'ps -u $USER -o comm'
zstyle ':completion:*' insert-tab false
zstyle ':completion:*' list-dirs-first  true
zstyle ':completion:*' accept-exact false
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
autoload -U compinit
compinit

# help
unalias  run-help 2>/dev/null
autoload run-help

# stalk other users on the system
watch=(notme)

# Don't use zsh builtin which
(( $+aliases[which] )) && unalias which

# Suffix alias

for ext in txt conf; do
  alias -s ${ext}=${EDITOR:-vim}
  unset ext
done

for ext in html htm org com net; do
  alias -s ${ext}=${BROWSER:-firefox}
  unset ext
done

# keybinds
bindkey -v
bindkey 'OQ'                          history-incremental-search-backward # F2
bindkey -M vicmd 'dd'                   vi-kill-line
bindkey -M vicmd 'D'                    vi-kill-eol
bindkey -M vicmd 'K'                    run-help
bindkey -M vicmd '\e/'                  'undefined-key'
bindkey -M viins '^H'                   backward-delete-char
bindkey -M viins '\e.'                  insert-last-word
bindkey -M viins '^Xm'                  _most_recent_file
bindkey -M menuselect '^[[Z'            reverse-menu-complete
if [[ -n ${terminfo[kLFT]} ]]; then 
  bindkey -M viins "${terminfo[kLFT]}"  vi-backward-word
  bindkey -M vicmd "${terminfo[kLFT]}"  vi-backward-word
fi
if [[ -n ${terminfo[kLFT]} ]]; then
  bindkey -M viins "${terminfo[kRIT]}"  vi-forward-word
  bindkey -M vicmd "${terminfo[kRIT]}"  vi-forward-word
fi
bindkey -M emacs '^[ '                  magic-space
bindkey -M emacs '^[!'                  expand-history
bindkey '^Z' undo
# code from ft of #zsh & the debian project to bind keys consistently.
typeset -A key
key=(
  Home      "${terminfo[khome]}"
  End       "${terminfo[kend]}"
  Insert    "${terminfo[kich1]}"
  Delete    "${terminfo[kdch1]}"
  Up        "${terminfo[kcuu1]}"
  Down      "${terminfo[kcud1]}"
  Left      "${terminfo[kcub1]}"
  Right     "${terminfo[kcuf1]}"
  PageUp    "${terminfo[kpp]}"
  PageDown  "${terminfo[knp]}" 
  BackSpace "${terminfo[kbs]}"
)

function bind2maps () {
  local i sequence widget
  local -a maps

  while [[ "$1" != "--" ]]; do
    maps+=( "$1" )
    shift
  done
  shift

  sequence="${key[$1]}"
  widget="$2"

  [[ -z "$sequence" ]] && return 1

  for i in "${maps[@]}"; do
    bindkey -M "$i" "$sequence" "$widget"
  done
}

bind2maps emacs             -- Home       beginning-of-line
bind2maps       viins vicmd -- Home       vi-beginning-of-line
bind2maps emacs             -- End        end-of-line
bind2maps       viins vicmd -- End        vi-end-of-line
bind2maps emacs viins       -- Insert     overwrite-mode
bind2maps             vicmd -- Insert     vi-insert
bind2maps emacs             -- Delete     delete-char
bind2maps       viins vicmd -- Delete     vi-delete-char
bind2maps emacs viins vicmd -- Up         up-line-or-history
bind2maps emacs viins vicmd -- Down       down-line-or-history
bind2maps emacs             -- Left       backward-char
bind2maps       viins vicmd -- Left       vi-backward-char
bind2maps emacs             -- Right      forward-char
bind2maps       viins vicmd -- Right      vi-forward-char
bind2maps       viins       -- BackSpace  backward-delete-char

zle -N edit-command-line; bindkey '^E' edit-command-line

unfunction bind2maps; unset key 
unsetopt globassign
