#! /bin/bash

cpanm -vn Net::SSLeay
cpanm -n Alien::Build
git clone https://github.com/hakonhagland/Alien-GSL-Shared.git
cd Alien-GSL-Shared
cpanm -n -v --installdeps .
perl Makefile.PL
make
#make test  # Tests are failing currently
make install
cd ..
#cpanm Alien::GSL
cpanm Module::Build
mkdir -p xs
perl Build.PL
./Build installdeps --cpan_client cpanm
./Build
./Build test
