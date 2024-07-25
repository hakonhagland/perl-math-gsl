#! /bin/bash

cpanm -vn Net::SSLeay
cpanm -n Alien::Build
cpanm -vn Math::GSL::Alien@1.05
cpanm -n Module::Build
mkdir -p xs
perl Build.PL
./Build installdeps --cpan_client cpanm
./Build
./Build test
