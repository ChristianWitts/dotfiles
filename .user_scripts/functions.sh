#!/usr/bin/env bash
. lib.sh

function static-compile-nim {
    local NIM_ENTRY="$1"
    docker run \
        --rm \
        -v `pwd`:/usr/src/app \
        -w /usr/src/app \
        nimlang/nim:alpine \
            nim c --passL:-static "${NIM_ENTRY}"
}

function update-nim-devel {
    # Update the Nim@devel branch with the latest sources
    # and rebuild the binaries
    SRC=~/src/github.com/nim-lang/nim
    pushd $SRC
    git pull
    pushd ${SRC}/csources
    git pull
    sh build.sh
    popd
    bin/nim c koch
    ./koch boot -d:release
    ./koch tools
    popd
}

function golang-optimisation-dump {
    go build  -gcflags="-m" *.go
}

function get-current-swap {
    # Get current swap usage for all running processes
    # Erik Ljungstrom 27/05/2011
    # Modified by Mikko Rantalainen 2012-08-09
    # Pipe the output to "sort -nk3" to get sorted output
    # Modified by Marc Methot 2014-09-18
    # removed the need for sudo
    SUM=0
    OVERALL=0
    for DIR in `find /proc/ -maxdepth 1 -type d -regex "^/proc/[0-9]+"`
    do
        PID=`echo $DIR | cut -d / -f 3`
        PROGNAME=`ps -p $PID -o comm --no-headers`
        for SWAP in `grep VmSwap $DIR/status 2>/dev/null | awk '{ print $2 }'`
        do
            let SUM=$SUM+$SWAP
        done
        if (( $SUM > 0 )); then
            echo "PID=$PID swapped $SUM KB ($PROGNAME)"
        fi
        let OVERALL=$OVERALL+$SUM
        SUM=0
    done
    echo "Overall swap used: $OVERALL KB"
}

#function repo {
#    set -l repo_base ~/Workspace
#    set -l repo_path (find "${repo_base}" -mindepth 2 -maxdepth 2 -type d -name "*$argv*" | head -n 1)
#    if not test "$argv"; or not test "$repo_path"
#        cd "$repo_base"
#    else
#        echo "found ${repo_path}"
#        cd "$repo_path"
#    end
#}

function check_certs {
    local SERVER=$1
    echo | openssl s_client -showcerts -servername "${SERVER}" -connect "${SERVER}":443
}

function lb {
    local TODAY=$(date '+%Y-%m-%d')
    if [[ ! -a ~/logbook/"${TODAY}".md ]]; then
        cp ~/logbook/template.md ~/logbook/"${TODAY}".md
    fi
    vim ~/logbook/"${TODAY}".md
}

function man-preview {
    man -t "$@" | open -f -a Preview
}

function mkgc {
    local REPO=$1
    local HOST=$(awk '{split($0, a, ":"); print a[1]}' <<< $REPO | awk '{split($0, a, "@"); print a[2]}')
    local GH_NAME=$(awk '{split($0, a, ":"); print a[2]}' <<< $REPO)
    local BASE_NAME=$(dirname $GH_NAME)
    local REPO_NAME=$(awk '{split($0, a, "."); print a[1]}' <<< $(basename $GH_NAME))
    [ -d ~/src/${HOST}/${BASE_NAME} ] || mkdir -p ~/src/${HOST}/${BASE_NAME}
    git clone $REPO ~/src/${HOST}/${BASE_NAME}/${REPO_NAME}
    cd ~/src/${HOST}/${BASE_NAME}/${REPO_NAME}
}

function update-things {
    update-nim-devel \
 && rustup self update \
 && rustup update \
 && brew upgrade \
 && brew cleanup \
 && choosenim update self \
 && choosenum update stable \
 && nimble update \
 && gcloud components update
}
