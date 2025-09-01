# ~/.bash_extras

#
if [ -d "$HOME/.cargo/bin" ] ; then
    PATH="$HOME/.cargo/bin:$PATH"
fi

#
if [ -d "$HOME/go/bin" ] ; then
    PATH="$HOME/go/bin:$PATH"
    export GOROOT="/usr/local/go"
    export GOPATH="$HOME/go"
fi

#
export PS1='\[\e[0;92m\]\u\[\e[0;97m\]@\[\e[0;92m\]\h \[\e[0;93m\]\w\[\e[0;91m\]$(__git_ps1)\n\[\e[0;32m\]└─\[\e[0m\]$ \[\e[0m\]'
