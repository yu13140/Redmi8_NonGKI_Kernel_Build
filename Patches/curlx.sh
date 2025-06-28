curlx_func () {
if [[ -z $2 ]]; then
    curl --progress-bar -LJ $1
else
    curl --progress-bar -LJ $1 -o $2
fi
}

alias curlx='curlx_func'