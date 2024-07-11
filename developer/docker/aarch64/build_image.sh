#! /bin/bash

GSL_VERSION=2.8
GSL_DIR=/opt/gsl/gsl-${GSL_VERSION}
PERL_DIR=/usr/local/perl
PERL_VERSION=perl-5.38.2
docker build --build-arg GSL_VERSION=$GSL_VERSION --build-arg GSL_DIR=$GSL_DIR \
             --build-arg PERL_DIR=$PERL_DIR --build-arg PERL_VERSION=$PERL_VERSION \
             -t perl-math-gsl-aarch64-cross .

