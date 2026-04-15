# ~/.profile: executed by Bourne-compatible login shells.

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

#
if [ -d "$HOME/bin" ] && [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    PATH="$HOME/bin:$PATH"
fi

#
if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    PATH="$HOME/.local/bin:$PATH"
fi

#
if [ -d "$HOME/.npm-global/bin" ] && [[ ":$PATH:" != *":$HOME/.npm-global/bin:"* ]]; then
    PATH="$HOME/.npm-global/bin:$PATH"
fi

#
if [ -d /snap/go/current ]; then
    export GOROOT=/snap/go/current
fi

if [ -d "$HOME/.local/go" ]; then
    export GOPATH="$HOME/.local/go"
fi

if [ -d "$GOPATH/bin" ] && [[ ":$PATH:" != *":$GOPATH/bin:"* ]]; then
    PATH="$GOPATH/bin:$PATH"
fi

#
mesg n 2> /dev/null || true
