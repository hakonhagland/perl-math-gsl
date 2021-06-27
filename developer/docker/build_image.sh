#! /bin/bash

branch=master
if (( $# == 1 )) ; then
    branch="$1"
fi
docker build --build-arg branch="$branch" -t math-gsl-ubuntu-2004 .
