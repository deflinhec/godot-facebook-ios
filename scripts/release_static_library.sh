#!/bin/bash

PLUGIN="facebook"

# Compile Plugin
./scripts/generate_static_library.sh $PLUGIN release $1
./scripts/generate_static_library.sh $PLUGIN release_debug $1
mv ./bin/${PLUGIN}.release_debug.a ./bin/${PLUGIN}.debug.a

# Move to release folder
rm -rf ./bin/release
mkdir ./bin/release
rm -rf ./bin/release/${PLUGIN}/facebook/bin
mkdir -p ./bin/release/${PLUGIN}/facebook/bin
rm -rf ./bin/release/${PLUGIN}/facebook/lib
mkdir -p ./bin/release/${PLUGIN}/facebook/lib

# Move Plugin
mv ./bin/${PLUGIN}.{release,debug}.a ./bin/release/${PLUGIN}/facebook/bin
cp ./plugin/${PLUGIN}/config/${PLUGIN}.gdip ./bin/release/${PLUGIN}

touch ./bin/release/${PLUGIN}/facebook/lib/PUT_HERE_FACEBOOK_SDK
