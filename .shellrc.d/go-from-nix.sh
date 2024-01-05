IFS=' '

NEW=(${(@s/ /)NIX_PROFILES})

for p in $NEW; do
    GOPATH="$p/share/go:$GOPATH"
done
