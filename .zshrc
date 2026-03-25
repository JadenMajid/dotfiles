# .zshrc - Modern & Fast Setup (No Oh-My-Zsh)

# Paths
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export EDITOR='nvim'

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# Keybindings (Fish-like)
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search
bindkey '^P' up-line-or-search
bindkey '^N' down-line-or-search

# Plugins (Assuming installed via Pacman/Yay)
# If not installed, these lines will just be ignored
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh ] && source /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Tools
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# Aliases
alias ls='eza --icons'
alias ll='eza -lh --icons --grid --git'
alias la='eza -ah --icons'
alias cat='bat' # Modern cat if installed
alias v='nvim'
alias cd='z'

# Fix SSH issues common with OMZ
unset STY
