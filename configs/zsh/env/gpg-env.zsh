# Force GPG_TTY to be a tty so pinentry won't hang
# and I don't have to turn off signing on my repos
export GPG_TTY=$(tty)
