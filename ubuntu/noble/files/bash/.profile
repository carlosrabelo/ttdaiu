# NPM global bin path
if [ -d "$HOME/.npm-global/bin" ] && [[ ":$PATH:" != *":$HOME/.npm-global/bin:"* ]]; then
    PATH="$HOME/.npm-global/bin:$PATH"
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
