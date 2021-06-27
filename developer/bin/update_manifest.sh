#! /bin/bash

if (( $# != 2 )) ; then
    echo "Bad arguments. Expected previous version and new version"
    exit
fi
prev="$1"
new="$2"
fn=MANIFEST
cd ../..
if [[ ! -f $fn ]] ; then
    echo "Cannot find $fn. Abort."
    exit
fi

perl -i -spE 's/^(.*pm\.)($prev)$/$1$2\n$1$new/' -- -prev=$prev -new=$new -- $fn
perl -i -spE 's/^(.*wrap\.)($prev\.c)$/$1$2\n$1${new}.c/' -- -prev=$prev -new=$new -- $fn
