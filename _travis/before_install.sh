#!/bin/bash
set -ev

_get_gsl () {
    # only download/compile/install if not cached
    if [ ! -d "gsl-$1" ]; then
        wget -q ftp://ftp.gnu.org/gnu/gsl/gsl-$1.tar.gz
        tar zxpf gsl-$1.tar.gz
        cd gsl-$1
        ./configure --prefix /tmp/gsl-$1
        make -j2
        make -j2 install
        cd ..
    fi
}

get_gsl () {
    _get_gsl $1 &> /dev/null
}

_get_master_gsl () {
    rm -rf /tmp/gsl-master
    if [ ! -d "gsl-master" ]; then
        git clone git://git.savannah.gnu.org/gsl.git gsl-master
        cd gsl-master
    else
        cd gsl-master
        ls -la
        git pull origin master
    fi

    ./autogen.sh
    ./configure --enable-maintainer-mode --prefix /tmp/gsl-master
    make -j2
    make -j2 install
    cd ..
}

get_master_gsl () {
    _get_master_gsl &> /dev/null
}

cpanm -n PkgConfig
export ORIG_DIR=`pwd`
echo ORIG_DIR=$ORIG_DIR
cd /tmp
get_gsl 1.15
get_gsl 1.16
get_gsl 2.0
get_gsl 2.1
get_gsl 2.2.1
get_master_gsl

ls -la /tmp/
ls -la /tmp/gsl-2.2.1/bin
cd /home/travis/build/leto/math--gsl
LD_LIBRARY_PATH=/tmp/gsl-2.2.1/lib:$LD_LIBRARY_PATH PATH=/tmp/gsl-2.2.1/bin:$PATH perl Build.PL && ./Build && ./Build dist # create a CPAN dist with latest supported GSL release
cp Math-GSL*.tar.gz /tmp
ls -la /tmp/Math-GSL*.tar.gz # now we have a CPAN dist to test on each version of GSL
cd $ORIG_DIR

