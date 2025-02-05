#!/bin/zsh

mv -f "$HOME/.config" "$HOME/.config-$RANDOM.backup"

mkdir -p "$HOME/.config/zsh"
mkdir -p "$HOME/.local/share"
mkdir -p "$HOME/.local/state"
mkdir -p "$HOME/.cache"

cat > "$HOME/.zshenv" << EOF
export XDG_CONFIG_HOME="\$HOME/.config"
export XDG_DATA_HOME="\$HOME/.local/share"
export XDG_STATE_HOME="\$HOME/.local/state"
export XDG_CACHE_HOME="\$HOME/.cache"
export ZDOTDIR="\$XDG_CONFIG_HOME/zsh"

if [ -f "\$ZDOTDIR/.zshenv" ]; then
    source "\$ZDOTDIR/.zshenv"
fi
EOF

source "$HOME/.zshenv"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

TEMP_CONFIG_HOME=$(mktemp -d)

git clone https://github.com/gradddev/.config.git "$TEMP_CONFIG_HOME"

rsync -av "$TEMP_CONFIG_HOME/" "$XDG_CONFIG_HOME/"

git clone --recursive https://github.com/sorin-ionescu/prezto.git "$ZDOTDIR/.zprezto"

setopt EXTENDED_GLOB
for rcfile in "$ZDOTDIR"/.zprezto/runcoms/^(README.md)(.N); do
    if [ ! -f "$ZDOTDIR/.${rcfile:t}" ]; then
        cp "$rcfile" "$ZDOTDIR/.${rcfile:t}"
    fi
done

source "$ZDOTDIR/.zprofile"

if [ ! -d "$Home/Developer" ]; then
    mkdir -p "$Home/Developer"
fi

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    yes | ssh-keygen -t ed25519 -N '' -f "$HOME/.ssh/id_ed25519" -C "mbp14"
fi

sudo scutil --set HostName mbp14
sudo scutil --set LocalHostName mbp14
sudo scutil --set ComputerName mbp14

dscacheutil -flushcache

brew bundle --file "$XDG_CONFIG_HOME/Brewfile"
