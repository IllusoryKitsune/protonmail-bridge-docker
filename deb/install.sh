#!/bin/bash
set -ex

# Repack deb (remove unnecessary dependencies)
mkdir deb
wget -i /PACKAGE -O /deb/protonmail.deb
cd deb
ar x -v protonmail.deb
mkdir control
tar zxvf control.tar.gz -C control
# libgcc1 is a transitional/gone package on Debian sid; the current runtime
# library is libgcc-s1. Using the old name breaks dpkg dependency resolution.
sed -i "s/^Depends: .*$/Depends: libgl1, libc6, libsecret-1-0, libstdc++6, libgcc-s1/" control/control
cd control
tar zcvf ../control.tar.gz .
cd ../

ar rcs -v /protonmail.deb debian-binary control.tar.gz data.tar.gz
