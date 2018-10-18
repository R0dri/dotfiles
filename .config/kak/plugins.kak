# ╭─────────────╥───────────────────╮
# │ Author:     ║ File:             │
# │ Andrey Orst ║ plugins.kak       │
# ╞═════════════╩═══════════════════╡
# │ plugins for Kakoune with        │
# │ settings                        │
# ╞═════════════════════════════════╡
# │ Rest of .dotfiles:              │
# │ GitHub.com/andreyorst/dotfiles  │
# ╰─────────────────────────────────╯

# Plugin manager
plug "andreyorst/plug.kak"

# Extended text objects and selections
plug "delapouite/kakoune-text-objects"
plug "occivink/kakoune-vertical-selection"

# Wrapper for GDB
plug "occivink/kakoune-gdb"

# fzf integration
plug "andreyorst/fzf.kak" %{
    map -docstring 'fzf mode' global normal '<c-p>' ': fzf-mode<ret>'
    set-option global fzf_preview_width '65%'
    evaluate-commands %sh{
        if [ ! -z "$(command -v fd)" ]; then
            echo "set-option global fzf_file_command 'fd . --no-ignore --type f --follow --hidden --exclude .git --exclude .svn'"
        else
            echo "set-option global fzf_file_command \"find . \( -path '*/.svn*' -o -path '*/.git*' \) -prune -o -type f -follow -print\""
        fi
        if [ ! -z "$(command -v bat)" ]; then
            echo "set-option global fzf_highlighter 'bat --color=always --style=plain {}'"
        elif [ ! -z "$(command -v highlight)" ]; then
            echo "set-option global fzf_highlighter 'highlight'"
        fi
    }
}

# automatic pair insertion and surroundig
plug "alexherbo2/auto-pairs.kak" %{
    hook global WinCreate .* %{ auto-pairs-enable }
    map global user -docstring 'surround selection' 's' ': auto-pairs-surround<ret>'
}

plug "TeddyDD/kakoune-edit-or-dir" %{
    unalias global e
    alias global e edit-or-dir
}

