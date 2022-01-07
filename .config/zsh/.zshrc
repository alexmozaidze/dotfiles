# Disallow freezing terminal
stty -ixon

# Update PATH variable
export PATH=/sbin:~/.local/bin:~/.cargo/bin:~/.local/share/gem/ruby/3.0.0/bin:$PATH

# Set default pager for man to NeoVim (and enable syntax highlighting)
#export PAGER="nvim -c 'set filetype=man'"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export BAT_THEME="One Dark"

# Clear the console
clear

# Display some cool system info
#ufetch

# Check if running in tty and define some variables
cursor_normal='\e[2 q'
cursor_insert='\e[6 q'

# Set default editor
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Variable that contains path to current vim sessions directory
export VSD=~/.local/share/nvim/sessions

# Enable colors and change prompt:
autoload -U colors && colors
PS1="%B$([[ -v TMUX ]] && echo "%{$fg[red]%}" || echo "%{$fg[green]%}")[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~$([[ -v TMUX ]] && echo "%{$fg[red]%}" || echo "%{$fg[green]%}")]%{$reset_color%}$%b "

# History in cache directory:
HISTSIZE=100
SAVEHIST=100
[ -f ~/.cache/zsh/history ] && HISTFILE=~/.cache/zsh/history || mkdir -p ~/.cache/zsh/ && touch ~/.cache/zsh/history && HISTFILE=~/.cache/zsh/history

# Exporting default ls colors (needed for colored tab-complete output)
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:'

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Keybindings
bindkey -s '^x' 'startx\n'
bindkey -s '^t' 'tmux\n'
bindkey -s '^f' 'vifm\n'

# Change cursor shape for different vi modes.
function zle-keymap-select {
	if [[ ${KEYMAP} == vicmd ]] ||
		[[ $1 = 'block' ]]; then
			echo -ne ${cursor_normal}

	elif [[ ${KEYMAP} == main ]] ||
		[[ ${KEYMAP} == viins ]] ||
		[[ ${KEYMAP} = '' ]] ||
		[[ $1 = 'beam' ]]; then
	echo -ne ${cursor_insert}
	fi
}
zle -N zle-keymap-select

_fix_cursor() {
	echo -ne ${cursor_insert}
}

precmd_functions+=(_fix_cursor)

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line


# Load aliases and shortcuts if existent.
[ -f "$HOME/.config/shortcutrc" ] && source "$HOME/.config/shortcutrc"
[ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/aliasrc"

[ "$(tty)" = "/dev/tty1" ] && startx

# Source insult script
source ~/.local/bin/zsh-insult

# Syntax highlight (needs to be at the end)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2> /dev/null

