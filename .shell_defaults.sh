# Aliases and Defaults
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

if [ -n "$(command -v dash)" ] && [ -n "$(command -v kak)" ]; then
    export KAKOUNE_POSIX_SHELL=$(command -v dash)
fi

if [ -n "$(command -v exa)" ]; then
    unset LS_COLORS
    unset LSCOLORS
    alias ls="exa"
    alias la="exa -la"
    alias l="exa -l"
    alias ll="exa -l"
fi

if [ -n "$(command -v kak)" ]; then
    export EDITOR="kak"
elif [ -n "$(command -v emacs)" ]; then
    export EDITOR="emacs"
else
    export EDITOR="vi"
fi

alias e="$EDITOR"

alias gti="git"
alias g="git"

# Edit things in apropriate environment
alias zshconf="$EDITOR ~/.zshrc"
alias tmuxconf="$EDITOR ~/.tmux.conf"
alias kakconf="kak ~/.config/kak/kakrc"
alias emacsconf="emacs ~/.emacs.d/config.org"

alias less="less --tabs 4"

# ultimate alias to create and attach to tmux sessions
alias tmux="tmux new-session -d -s \>_ 2>/dev/null; tmux new-session -t \>_ \; set-option destroy-unattached"

# to use sudo with aliases
alias sudo="sudo "

# Functions
# ‾‾‾‾‾‾‾‾‾

# create dir and cd into it
mkcd() { mkdir -p $1 && cd $1; }

# convert webm to mp4
webmp4() {
    if [ -n "$(command -v ffmpeg)" ]; then
        echo "ffmpeg is not installed" >&2
        return 1
    fi
    while [ $# -ne 0 ]; do
        ffmpeg -i "$1" "${1%.*}.mp4"
        shift
    done
}

# gifify wrapper for fast gif creating
gif() {
    if [ -n "$(command -v gifify)" ]; then
        gifify $1 -o ${1#.*}.gif --colors 256 --compress 0 --fps 30
    else
        echo "gifify is not installed" >&2
        return 1
    fi
}

# Create new C project from template
cnew() {
    if [ $# -lt 1 ]; then
        echo "At leas 1 argument required" >&2
        return 1
    fi

    git=
    readme=
    empty=
    while [ $# -gt 0 ]; do
        case $1 in
            (--add-flag) shift; flags="$flags\n$1" ;;
            (--git) git="true"             ;;
            (--readme) readme="true"       ;;
            (--empty) empty="true"         ;;
            (--help)
                echo "usage: cnew [--add-flag <compile flag>] [--git] [--readme] [--help] project_name\n" >&2
                echo "  --add-flag <flag>: add compile flag to project compile_flags.txt file" >&2
                echo "  --git:             create git repository in project" >&2
                echo "  --readme:          create empty readme file for a project" >&2
                return 0 ;;
            (*) project_name="$1" ;;
        esac
        shift
    done

    mkdir $project_name >/dev/null 2>&1
    res=$?
    if [ $res -ne 0 ]; then
        echo "Error creating a project '$project_name': $res" >&2
        return $res
    fi

    if [ -z "$empty" ]; then
        cp ~/.dotfiles/.c_project_template/* $project_name/ >/dev/null 2>&1
        res=$?
        if [ $res -ne 0 ]; then
            rm -rf $project_name
            echo "Error creating a project '$project_name': $res" >&2
            return $res
        fi
    fi

    if [ -n "$flags" ] && [ -z "$empty" ]; then
        printf "%s\n" "$flags" >> $project_name/compile_flags.txt
        res=$?
        if [ $res -ne 0 ]; then
            rm -rf $project_name
            echo "Error creating a project '$project_name': $res" >&2
            return $res
        fi
    fi

    if [ -n "$git" ]; then
        git init $project_name
        res=$?
        if [ $res -ne 0 ]; then
            rm -rf $project_name
            echo "Error creating a project '$project_name': $res" >&2
            return $res
        fi
    fi

    if [ -n "$readme" ] && [ -z "$empty" ]; then
        printf "%s\n" "# $project_name" > $project_name/README.md
        res=$?
        if [ $res -ne 0 ]; then
            rm -rf $project_name
            echo "Error creating a project '$project_name': $res" >&2
            return $res
        fi
    fi

    if [ $res -eq 0 ]; then
        echo "Created project: $project_name"
    fi
}

# Package manager wrappers
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
for pm in yay pacman dnf yum apt; do
    if [ -n "$(command -v $pm)" ]; then
        alias pm="pm_$pm"
        break
    fi
done

pm_yay() {
    cmd="$1"
    shift
    case "$cmd" in
        (install) yay -S "$@"     ;;
        (update)  yay -Syyu "$@"  ;;
        (remove)  yay -Rsc "$@"   ;;
        (search)  yay -Ss "$@"    ;;
        (*)       yay "$cmd" "$@" ;;
    esac
}

pm_packman() {
    cmd="$1"
    shift
    case "$cmd" in
        (install) sudo pacman -S "$@"     ;;
        (update)  sudo pacman -Syyu "$@"  ;;
        (remove)  sudo pacman -Rsc "$@"   ;;
        (search)  pacman -Ss "$@"         ;;
        (*)       sudo pacman "$cmd" "$@" ;;
    esac
}

pm_dnf() {
    cmd="$1"
    shift
    case "$cmd" in
        (install) sudo dnf install "$@" ;;
        (update)  sudo dnf upgrade "$@" ;;
        (remove)  sudo dnf remove "$@"  ;;
        (search)  dnf search "$@"       ;;
        (*)       sudo dnf "$cmd" "$@"  ;;
    esac
}

pm_yum() {
    cmd="$1"
    shift
    case "$cmd" in
        (install) sudo yum install "$@" ;;
        (update)  sudo yum update "$@"  ;;
        (remove)  sudo yum remove "$@"  ;;
        (search)  yum search "$@"       ;;
        (*)       sudo yum "$cmd" "$@"  ;;
    esac
}

if [ -n "${PATH##*termux*}" ]; then
    pm_apt() {
        cmd="$1"
        shift
        case "$cmd" in
            (install) sudo apt install "$@" ;;
            (update)  sudo apt update "$@"  ;;
            (remove)  sudo apt remove "$@"  ;;
            (search)  apt search "$@"       ;;
            (*)       sudo apt "$cmd" "$@"  ;;
        esac
    }
else
    pm_apt() {
        cmd="$1"
        shift
        case "$cmd" in
            (install) apt install "$@" ;;
            (update)  apt update && apt upgrade "$@"  ;;
            (remove)  apt remove "$@" ;;
            (search)  apt search "$@" ;;
            (*)       apt "$cmd" "$@" ;;
        esac
    }
fi
