# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -lah'
alias r='ranger'
alias s='cd /srv/'
alias cgit='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=/'
alias sudo-cgit='sudo /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=/'

alias p='just --justfile /srv/justfile --dotenv-filename /srv/server.env --working-directory=/srv/'
