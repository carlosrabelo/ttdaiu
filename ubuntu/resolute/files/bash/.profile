# User local bins
if [ -d "$HOME/bin" ] && [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# NPM global bin path
if [ -d "$HOME/.npm-global/bin" ] && [[ ":$PATH:" != *":$HOME/.npm-global/bin:"* ]]; then
    PATH="$HOME/.npm-global/bin:$PATH"
fi

# Cargo / rustup
if [ -d "$HOME/.cargo/bin" ] && [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
    PATH="$HOME/.cargo/bin:$PATH"
fi

# OpenCode
if [ -d "$HOME/.opencode/bin" ] && [[ ":$PATH:" != *":$HOME/.opencode/bin:"* ]]; then
    PATH="$HOME/.opencode/bin:$PATH"
fi

# Go paths
if [ -d /snap/go/current ]; then
    export GOROOT=/snap/go/current
fi
if [ -d "$HOME/.local/go" ]; then
    export GOPATH="$HOME/.local/go"
fi
if [ -d "$GOPATH/bin" ] && [[ ":$PATH:" != *":$GOPATH/bin:"* ]]; then
    PATH="$GOPATH/bin:$PATH"
fi
