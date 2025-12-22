# Go environment

[[ ! -d "$GOPATH" ]] && mkdir -p "$GOPATH"/{bin,src,pkg}

export PATH="$GOPATH/bin:$PATH"
