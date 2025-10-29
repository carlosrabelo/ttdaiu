# ~/.bash_extras

#
export PS1='\[\e[0;92m\]\u\[\e[0;97m\]@\[\e[0;92m\]\h \[\e[0;93m\]\w\[\e[0;91m\]$(__git_ps1)\n\[\e[0;32m\]└─\[\e[0m\]$ \[\e[0m\]'

#
[[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"

#
[[ -d "$HOME/.npm-global/bin" && ":$PATH:" != *":$HOME/.npm-global/bin:"* ]] && export PATH="$HOME/.npm-global/bin:$PATH"

#
export GOROOT=/snap/go/current
export GOPATH=~/.local/go
export PATH=$GOPATH/bin:$PATH
