#	zmodload zsh/zprof

clear
# clear && fastfetch

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc
_cache="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
_config="$HOME/.p10k.zsh"
[[ -r "$_cache" ]] && source "$_cache"
[[ -f "$_config" ]] && source "$_config"

# -----------------
# Reset cache daily
# -----------------
_evalcache_clear_today()
{
	local DIR="$HOME/.zsh-evalcache/"
	local FLAG_FILE="$DIR/reset.flag"
	local TODAY=$(date +%Y-%m-%d)
	if [[ ! -f "$FLAG_FILE" ]]; then # Check kung na-reset na ngayong araw
		mkdir -p "$DIR"
		touch "$FLAG_FILE"
	fi
	local LAST_RESET=$(cat "$FLAG_FILE")
	if [[ "$LAST_RESET" == "$TODAY" ]]; then
		return  # Skip reset kung tapos na today
	fi
	echo "Resetting _evalcache..." # RESET EVALCACHE COMMAND DITO
	rm -rf "$DIR/"*  # Ilagay ang actual command na pang-reset
	echo -n "$TODAY" > "$FLAG_FILE" # Update flag file
	echo "Evalcache reset done for today."
}
_evalcache_clear_today

# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#

# -----------------
# Zsh configuration
# -----------------

#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
# bindkey -e
# bindkey -v

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# -----------------
# Zim configuration
# -----------------

# Use degit instead of git as the default tool to install and update modules.
#zstyle ':zim:zmodule' use 'degit'

# --------------------
# Module configuration
# --------------------

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
#zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# Disable automatic widget re-binding on each precmd. This can be set when
# zsh-users/zsh-autosuggestions is the last module in your ~/.zimrc.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=247'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=242'


# ------------------
# Pre-Initialize modules
# ------------------


ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi

# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
_defer=true
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
	_defer=false # don't defer on update
	source ${ZIM_HOME}/zimfw.zsh init
fi

# ------------------
# Initialize modules
# ------------------

# Initialize zsh-defer.
_path="${ZIM_HOME}/modules/zsh-defer/zsh-defer.plugin.zsh"
if $_defer && [ -f $_path ]; then
	source $_path
else
	alias zsh-defer=eval
	_defer=false
fi


# Initialize evalcache.
_path=${ZIM_HOME}/modules/evalcache/evalcache.plugin.zsh
if [ -f $_path ]; then
	source $_path
else
	_evalcache(){ eval "$("$@")"; }
fi

if ! $_defer; then
	source ${ZIM_HOME}/init.zsh
else
	removes=(
		# powerlevel10k
		# asciiship
	)
	must_defer=(
		environment
		input
		git
		utility
		termtitle
		git-info
		duration-info
		completion
		F-Sy-H
		zsh-history-substring-search
		zsh-autosuggestions
	)
	for zline in ${(f)"$(<$ZIM_HOME/init.zsh)"}; do
		if [[ $zline == source* ]]; then
			local must_remove=false
			for remove in "${removes[@]}"; do
				if [[ $zline == *"/modules/$remove/"* ]]; then
					must_remove=true
					break
				fi
			done
			if $must_remove; then
				continue
			fi
			local defer_source=false
			for must in "${must_defer[@]}"; do
				if [[ $zline == *"/modules/$must/"* ]]; then
					defer_source=true
					break
				fi
			done
			if $defer_source; then
				zsh-defer -c "${zline}"
			else
				eval "${zline}"
			fi
		else
			eval "${zline}"
		fi
	done
fi


# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key
# }}} End configuration added by Zim install

#
# Other initializations:
#
_evalcache zoxide init zsh --cmd cd
_evalcache fzf --zsh

#
# bindings
#
(( ! ${+functions[p10k]} )) || p10k finalize
# clear

# zprof
