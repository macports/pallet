#!/bin/bash

if [ "$(id -u)" != "0" ]; then
    echo "This build script requires you to run as root. " 1>&2
    exit 1
fi

cd Pallet/
make
build/Build/Products/Debug/Pallet.app/Contents/MacOS/Pallet

