# GPG management sanity aliases
alias gpg-list-secrets='gpg --list-secret-keys --with-subkey-fingerprint'
alias gpg-list='gpg --list-keys --with-subkey-fingerprints'
alias gpg-list-full='gpg --list-secret-keys --with-keygrip --with-subkey-fingerprints'
alias gpg-fix='gpgconf --kill gpg-agent && gpgconf --launch gpg-agent'
