# source /usr/share/cachyos-fish-config/cachyos-config.fish

function fish_greeting
    # Do nothing to hide the initial fastfetch message
end

# Commands to run in interactive sessions go here

# ==========================================
# 1. Environment Variables
# ==========================================
# 'set -gx' exports the variable globally
set -gx EDITOR nvim
set -gx VISUAL nvim

# ==========================================
# 2. Path Management
# ==========================================
# fish_add_path automatically prepends to $PATH and prevents duplicates
fish_add_path ~/.local/bin
fish_add_path ~/go/bin
fish_add_path ~/bin

# ==========================================
# 3. Abbreviations (Fish's "Aliases")
# ==========================================
# Fish prefers abbreviations over aliases. They expand as you type,
# so your history stores the actual command instead of the shortcut.
abbr -a g git
abbr -a gs 'git status'
abbr -a ll 'ls -lah --color=auto'
abbr -a c clear

# ==========================================
# 4. fzf Integration
# ==========================================
# Set default fzf styling and behavior
set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border"
set -gx FZF_CTRL_R_OPTS "--sort --exact"

# For fzf v0.48.0 or newer:
# This automatically sets up tab completion and keybindings (Ctrl+R, Ctrl+T, Alt+C)
fzf --fish | source

# If you are on an older version of fzf, comment out the line above and use:
# fzf_key_bindings
# ==========================================

alias vim="nvim"

function fish_prompt
    set_color $fish_color_cwd
    printf '%s' (prompt_pwd)

    # 3. Reset text formatting and print the final prompt symbol
    set_color normal
    printf '$ '
end

fish_vi_key_bindings

# Define your custom key bindings inside this specific function
function fish_user_key_bindings
    # "gh" to beginning of line in normal (default) mode
    bind -M default gh beginning-of-line

    # "gl" to end of line in normal (default) mode
    bind -M default gl end-of-line
end
