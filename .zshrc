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

zmodload zsh/zprof

# # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi
#
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

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
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
	source ${ZIM_HOME}/zimfw.zsh init
fi

# ------------------
# Initialize modules
# ------------------

# Initialize zsh-defer.
_defer=true
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
		# asciiship
		# completion
		# zsh-vi-mode
		# powerlevel10k
#		zsh-syntax-highlighting
#		zsh-history-substring-search
#		zsh-autosuggestions
	)
	must_defer=(
		git
		input
		duration-info
		git-info
		# evalcache
		#zsh-syntax-highlighting
		zsh-autosuggestions
		# asciiship
		zsh-history-substring-search
		completion
		termtitle
		# zsh-defer
		# termtitle
		# zsh-vi-mode
	)
#	_contains()
#	{
#		_found=false
#		for _e in "${_l[@]}"; do
#			if [[ "$1" == *"/modules/$_e/"* ]]; then
#				_found=true
#				break
#			fi
#		done
#		return $_found
#	}

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
#			if _l="${must_remove[@]}" _contains "$zline"; then
#				continue
#			fi
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


# Initialiaze zsh-syntax-highlighting
# Fix globbing issue in .zim/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# change:
#		for highlighter_dir ($1/*/(/)); do
# to:
#		for highlighter_dir ($(bash -c "echo $1/*/")); do
#_dir="${HOME}/.zim/modules/zsh-syntax-highlighting"
#_path="${_dir}/zsh-syntax-highlighting.zsh"
_path="${HOME}/.zim/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
_raw(){ echo -n "$1" | sed -E 's/([][().*?+^$|{}\/])/\\\1/g'; }
_replace_once(){ sed -E "/^#/b; /$(_raw "$1")/!b; h; s/^/#/;p; g; s/$(_raw "$1")/$(_raw "$2")/g;" "$3"; }
_as_locked_file()
{
	file="$1"; shift
	if ! [ -f "$file" ]; then
		#_replace_once '($1/*/(/))' '($(bash -c "echo $1/*/"))' "$file"
		"$@" > "$file"
	fi
	echo -n "$file"
}
zsh-defer source $(_as_locked_file "$_path.fixed" _replace_once '($1/*/(/))' '($(bash -c "echo $1/*/"))' "$file")
#zsh-defer _evalcache _replace_once '($1/*/(/))' '($(bash -c "echo $1/*/"))' "$file"
#if ! [ -f "$_path.fixed" ]; then
#	cat "$_path" | _replace_once '($1/*/(/))' '($(bash -c "echo $1/*/"))' > "$_path.fixed"
#fi
#zsh-defer source "$_path.fixed"
#zsh-defer source "${HOME}/.zim/modules/completion/init.zsh"
#zsh-defer source "${HOME}/.zim/modules/zsh-history-substring-search/zsh-history-substring-search.zsh"
#zsh-defer source "${HOME}/.zim/modules/zsh-autosuggestions/zsh-autosuggestions.zsh"
#zsh-defer _replace_once '($1/*/(/))' '($(bash -c "echo $1/*/"))' "$_path"
#echo -n "$(_replace_once '($1/*/(/))' '($(bash -c "echo $1/*/"))' $_path)" > $_path
#zsh-defer -c "source $_path"
#(
#	cd "${_dir}"
#	zsh-defer _evalcache _replace_once '($1/*/(/))' '($(bash -c "echo $1/*/"))' $_path
#)

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
# zoxide
#
_evalcache zoxide init zsh --cmd cd

#
# fzf
#
_evalcache fzf --zsh

#zprof
