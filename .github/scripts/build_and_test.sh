#! /bin/bash

export LD_LIBRARY_PATH=${GSL_INST_DIR}/${TARBALL_GSL}/lib
export PATH="$GSL_INST_DIR"/"$TARBALL_GSL"/bin:"$PATH"
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
