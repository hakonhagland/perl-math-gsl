#! /bin/bash

./Build dist
DISTNAME=$(ls -1 Math*.tar.gz)
echo "MATH_GSL_DISTNAME=$DISTNAME" >> $GITHUB_ENV
echo "$DISTNAME" > math-gsl-dist-name.txt
