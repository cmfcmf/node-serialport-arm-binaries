#!/bin/bash

set -ev

source $HOME/.nvm/nvm.sh
nvm install 15
nvm use 15
npm install

VERSIONS=$(npm view @serialport/bindings versions --json)
ABI_VERSIONS=$(node node-abi-versions.js)

mkdir -p build
cd build

if [ -d "raspberry-tools" ]; then
    cd raspberry-tools
    git fetch origin --depth 1
    cd ..
else
    git clone --depth 1 https://github.com/raspberrypi/tools.git raspberry-tools
fi

verlte() {
    [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

echo $ABI_VERSIONS | jq -r -c '.[]' | while read LINE; do
    RUNTIME=$(echo $LINE | jq -r -c '.runtime')
    TARGET=$(echo $LINE | jq -r -c '.target')
    ABI=$(echo $LINE | jq -r -c '.abi')

    echo $RUNTIME
    echo $TARGET
    echo $ABI

    nvm install $(echo $TARGET | cut -f1 -d".")
    nvm use $(echo $TARGET | cut -f1 -d".")
    $(npm bin)/node-gyp install $(echo $TARGET | cut -f1 -d".")

    pids=""

    echo $VERSIONS | jq -r -c '.[]' | while read VERSION; do
        if verlte $VERSION 3.0.0; then
            echo "Skipping version $VERSION"
        else
            bash ../make_version.sh "$VERSION" "$RUNTIME-v$ABI"
            pids="$pids $!"

            if [ $( jobs | wc -l ) -ge $( nproc ) ]; then
                wait
            fi
        fi
    done

    wait $pids

    sleep 20
done

gh release delete bindings -y || true
gh release create bindings build/bindings-*.tar.gz --title bindings --notes "---"