#!/bin/bash

function _prompt_yn()
{
    while true; do
        read -p "$1 [y|n] " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

swapfile_first=0
while true; do
    case "$1" in
        ""|-h|--help)
            echo "usage: vim-process-swap file [swapfile [recoverfile]]" >&2
            return 1;;
        -s)
            shift
            swapfile_first=1;;
        *)
            break;;
    esac
done
realfile=`readlink -f "$1"`
path=`dirname "$realfile"`
realname=`basename "$realfile"`
if [ $swapfile_first -eq 1 ]; then
    swapfile=$realfile
    realname=${realname:1:-4}
    realfile="${path}/${realname}"
else
    swapfile=${2:-"${path}/.${realname}.swp"}
fi
recoverfile=${3:-"${path}/${realname}-recovered"}
lastresort=0
for f in "$realfile" "$swapfile"; do
    if [ ! -f "$f" ]; then
        echo "File $f does not exist." >&2
        return 1
    #elif fuser "$f"; then
    #    echo "File $f in use by process." >&2
    #    return 1
    fi
done
if [ -f "$recoverfile" ]; then
    echo "Recover file $recoverfile already exists. Delete existing recover file first." >&2
    return 1
fi
vim -u /dev/null --noplugin -r "$swapfile" -c ":wq $recoverfile"
if cmp -s "$realfile" "$recoverfile"; then
    rm "$swapfile" "$recoverfile"
elif [ "$realfile" -nt "$swapfile" ] && [ `stat -c%s "$realfile"` -gt `stat -c%s "$recoverfile"` ]; then
    echo "Swapfile is older than realfile, and recovered file is smaller than realfile"
    if _prompt_yn "Delete recovered file and swapfile without doing diff?"; then
        rm "$swapfile" "$recoverfile"
    else
        lastresort=1
    fi
else
    lastresort=1
fi

if [[ "$lastresort" -ne 0 ]]; then
    rm "$swapfile"
    vimdiff "$recoverfile" "$realfile"
    if _prompt_yn "Delete recovered file?"; then
        rm "$recoverfile"
    fi
fi


