#! /bin/bash

GSL_MIRROR=http://mirrors.kernel.org/gnu/gsl
TARBALL="$TARBALL_GSL".tar.gz

mkdir -p "$GSL_SRC_DIR"
cd "$GSL_SRC_DIR"
wget "$GSL_MIRROR"/"$TARBALL" --retry-connrefused --timeout=900
tar zxvf "$TARBALL"
cd "$TARBALL_GSL"
./configure --prefix "$GSL_INST_DIR"/"$TARBALL_GSL"
make -j$(nproc)
make install
