#! /bin/bash

echo "GSL_INST_DIR=${GITHUB_WORKSPACE}/gsl" >> $GITHUB_ENV
echo "GSL_SRC_DIR=${GITHUB_WORKSPACE}/gsl-source" >> $GITHUB_ENV
echo "TARBALL_GSL=gsl-$GSL_VERSION" >> $GITHUB_ENV