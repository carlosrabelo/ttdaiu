# ~/.profile: executed by Bourne-compatible login shells.

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

#
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

#
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

mesg n 2> /dev/null || true
