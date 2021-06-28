#! /bin/bash

export LD_LIBRARY_PATH=${GSL_DIR}/lib
export PATH=$GSL_DIR/bin:"$PATH"
export PATH=$PERL_DIR/bin:"$PATH"
export PKG_CONFIG_PATH="$GSL_DIR"/lib/pkgconfig
cpanm -vn Net::SSLeay
cpanm -n Alien::Build
if [[ $GITHUB_WORKFLOW == *"windows"* ]] ; then
    tempdir=$(mktemp -d)
    curdir=$PWD
    cd $tempdir
    git clone https://github.com/PerlAlien/Alien-GSL.git
    cd Alien-GSL
    git fetch origin pull/8/head:pr7_mm
    git checkout pr7_mm
    perl Makefile.PL
    make
    make test
    make install
    cd $curdir
else
    cpanm Alien::GSL
fi
cpanm Module::Build
mkdir -p xs
perl Build.PL
./Build installdeps --cpan_client cpanm
./Build
./Build test
echo "PATH=$PATH" >> $GITHUB_ENV
