#! /bin/bash

# NOTE: PWD=/home/runner/work/math--gsl--gha/math--gsl--gha
# NOTE: perl version 5.26.1 is already installed (on Ubuntu 20.04),
#   but we would like to not mess with that, so we install a custom perl.

if [[ $USE_PERL != "system" ]] ; then
    wget https://www.cpan.org/src/5.0/$USE_PERL
    ARCHIVE_TYPE=$(perl -pe 's/^.*\.([^.]*)$/$1/' <<<$USE_PERL)
    TAR_NAME=$(perl -pe 's/^(.*)\.[^.]*$/$1/' <<<$USE_PERL)
    if [[ $ARCHIVE_TYPE == 'gz' ]] ; then
        gunzip $USE_PERL
    elif [[ $ARCHIVE_TYPE == 'bz2' ]] ; then
        bunzip2 $USE_PERL
    else
        echo "Unknown archive type: $ARCHIVE_TYPE"
        exit 1
    fi
    tar xvf $TAR_NAME
    PERL_DIR=$(perl -pe 's/\.tar$//' <<<$TAR_NAME)
    cd $PERL_DIR
    sh Configure -des -Dprefix=$GITHUB_WORKSPACE/perl -Dman1dir=none -Dman3dir=none
    make
    make install
    export PATH=$GITHUB_WORKSPACE/perl/bin:$PATH
    echo "PATH=$PATH" >> $GITHUB_ENV
fi
perl --version
cpan -v
cpan App::cpanminus

