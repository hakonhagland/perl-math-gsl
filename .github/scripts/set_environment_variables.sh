#! /bin/bash

echo "PERL_NAME=$PERL_NAME" >> $GITHUB_ENV
echo "PERL_DIR=$PERL_DIR" >> $GITHUB_ENV
if [[ -n $PERL_DIR ]] ; then
    export PATH=$PERL_DIR/bin:"$PATH"
fi
echo "GSL_NAME=$GSL_NAME" >> $GITHUB_ENV
echo "GSL_DIR=$GSL_DIR" >> $GITHUB_ENV
if [[ -n $GSL_DIR ]] ; then
    export LD_LIBRARY_PATH=$GSL_DIR/lib
    export PATH=$GSL_DIR/bin:"$PATH"
    export PKG_CONFIG_PATH="$GSL_DIR"/lib/pkgconfig
fi

echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> $GITHUB_ENV
echo "PATH=$PATH" >> $GITHUB_ENV
echo "PKG_CONFIG_PATH=$PKG_CONFIG_PATH" >> $GITHUB_ENV
