#!/bin/bash

set -ev

VERSION="$1"
RUNTIME_ABI="$2"
WORK_DIR=package-$VERSION

echo $VERSION

rm -rf $WORK_DIR
mkdir $WORK_DIR

npm view @serialport/bindings@$VERSION dist.tarball | xargs curl | tar -xz -C $WORK_DIR

cd $WORK_DIR/package
npm install --ignore-scripts --silent --quiet --no-progress
node-gyp clean
node-gyp configure --arch=arm -- -I ../../../crosscompile.gypi
node-gyp build

zip ../../bindings-v$VERSION-$RUNTIME_ABI-arm7.zip build/Release/bindings.node

rm -rf $WORK_DIR