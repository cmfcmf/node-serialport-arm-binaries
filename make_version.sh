#!/bin/bash

set -ev

VERSION="$1"
RUNTIME_ABI="$2"
WORK_DIR=package-$VERSION

echo $VERSION

rm -rf $WORK_DIR
mkdir $WORK_DIR

GYP=$(npm bin)/node-gyp

npm view @serialport/bindings@$VERSION dist.tarball | xargs curl | tar -xz -C $WORK_DIR

cd $WORK_DIR/package
npm install --ignore-scripts --silent --quiet --no-progress
$GYP clean
$GYP configure --arch=arm -- -I ../../../crosscompile.gypi
$GYP build

tar -czf ../../bindings-v$VERSION-$RUNTIME_ABI-armv7.tar.gz build/Release/bindings.node

rm -rf $WORK_DIR