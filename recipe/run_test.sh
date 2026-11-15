#!/bin/sh

test "$PANDA_PRC_DIR" = "$PREFIX/etc/panda3d" || exit 1

mkdir -p test/build
cmake -S test -B test/build -G "Ninja"
cmake --build test/build --target all
