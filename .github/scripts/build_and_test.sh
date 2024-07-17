#! /bin/bash

cpanm -vn Net::SSLeay
cpanm -n Alien::Build
cpanm Math::GSL::Alien
cpanm Module::Build
mkdir -p xs
perl Build.PL
./Build installdeps --cpan_client cpanm
./Build
./Build test
