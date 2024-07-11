# Stage 1: Install necessary tools and libraries for cross-compilation
FROM ubuntu:noble AS cross-compile-tools

# Enable the foreign architecture and update package lists
RUN dpkg --add-architecture arm64

# Update the sources list to include ports.ubuntu.com for arm64 packages
RUN echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports noble main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports noble-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports noble-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports noble-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb [arch=amd64] http://archive.ubuntu.com/ubuntu noble main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb [arch=amd64] http://archive.ubuntu.com/ubuntu noble-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb [arch=amd64] http://archive.ubuntu.com/ubuntu noble-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb [arch=amd64] http://archive.ubuntu.com/ubuntu noble-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    rm -rf /etc/apt/sources.list.d/ubuntu.sources && \
    apt-get update

# Install cross-compilation tools and libraries
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    qemu-user-static \
    wget \
    tar \
    xz-utils \
    libssl-dev:arm64 \
    zlib1g-dev:arm64

# Stage 2: Cross-compile Perl for arm64 on x86_64
FROM cross-compile-tools AS cross-compile-perl

ARG PERL_VERSION=perl-5.38.2
ARG PERL_DIR=/usr/local/perl

# Set up environment variables for cross-compilation
ENV CC=aarch64-linux-gnu-gcc
ENV CXX=aarch64-linux-gnu-g++
ENV CROSS_COMPILE=aarch64-linux-gnu-
ENV ARCH=arm64

# Cross-compile Perl
WORKDIR /root
RUN wget https://www.cpan.org/src/5.0/${PERL_VERSION}.tar.gz && \
    tar -xzf ${PERL_VERSION}.tar.gz && \
    cd $PERL_VERSION && \
    ./Configure -des -Dprefix=${PERL_DIR} -Dcc=$CC -Duseshrplib -Darchname=$ARCH && \
    make -j$(nproc) && \
    make install

# Stage 3: Cross-compile Perl modules using the cross-compiled Perl
FROM cross-compile-tools AS cross-compile-modules

ARG GSL_VERSION=2.8
ARG GSL_DIR=/opt/gsl/gsl-${GSL_VERSION}
ARG PERL_DIR=/usr/local/perl

# Set up environment variables for cross-compilation
ENV CC=aarch64-linux-gnu-gcc
ENV CXX=aarch64-linux-gnu-g++
ENV CROSS_COMPILE=aarch64-linux-gnu-
ENV ARCH=arm64
ENV PATH="${PERL_DIR}/bin:${PATH}"

# Copy the cross-compiled Perl
COPY --from=cross-compile-perl ${PERL_DIR} ${PERL_DIR}

# Install cpanminus
#RUN wget -O /usr/local/bin/cpanm https://cpanmin.us && chmod +x /usr/local/bin/cpanm
RUN PERL_MM_USE_DEFAULT=1 cpan App::cpanminus
# RUN curl -L https://cpanmin.us | perl - App::cpanminus

# Compile Perl modules
WORKDIR /root

RUN cpanm --notest --force IO::Socket::SSL
RUN cpanm --notest --force Module::Build
# Install GSL with the correct architecture
# This will install the library in /opt/gsl

# NOTE: We need to install GSL from source before installing Alien::GSL since
#     Alien::GSL when downloading and installing GSL from source, will not provide
#     the cross-build flags --host and --build
RUN wget http://ftp.gnu.org/gnu/gsl/gsl-${GSL_VERSION}.tar.gz && \
    tar -xzf gsl-${GSL_VERSION}.tar.gz && \
    cd gsl-${GSL_VERSION} && \
    ./configure --host=aarch64-linux-gnu --build=x86_64-linux-gnu --prefix=${GSL_DIR} && \
    make -j$(nproc) && \
    make install

# Make sure Alien::GSL can find the cross-compiled GSL, such that it does not download
#  and compile GSL from source
ENV LD_LIBRARY_PATH=${GSL_DIR}/lib
ENV PKG_CONFIG_PATH=${GSL_DIR}/lib/pkgconfig
# Update PATH such that we can find the gsl-config script
ENV PATH="${GSL_DIR}/bin:$PATH"
RUN cpanm -v --notest --force Alien::GSL

RUN apt-get update && apt-get install -y git swig

# Clone and build perl-math-gsl
RUN git clone https://github.com/hakonhagland/perl-math-gsl.git && \
    cd perl-math-gsl && \
    perl Build.PL && \
    ./Build installdeps --cpan_client cpanm && \
    ./Build

# You can run the tests here if needed, but if you are debugging a failed test, you should
#   instead run the docker container interactively and run the tests manually there
#RUN cd perl-math-gsl && ./Build test

# Stage 4: Create the arm64 image
FROM arm64v8/ubuntu:latest
# Inherit the environment variables from the cross-compile-modules stage

ARG GSL_VERSION=2.8
ARG GSL_DIR=/opt/gsl/gsl-${GSL_VERSION}
ARG PERL_DIR=/usr/local/perl

ENV LD_LIBRARY_PATH=${GSL_DIR}/lib
ENV PKG_CONFIG_PATH=${GSL_DIR}/lib/pkgconfig
ENV PATH="${PERL_DIR}/bin:${PATH}"
# Update PATH such that we can find the gsl-config script
ENV PATH="${GSL_DIR}/bin:$PATH"

SHELL ["/bin/bash", "-c"]
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        curl \
        g++ \
        git \
        cpanminus \
        vim \
        sudo \
        wget \
        clang \
        swig \
        autoconf \
        libtool \
        libssl-dev \
        libz-dev \
        perl

# Copy compiled Perl and modules from the cross-compile stages
COPY --from=cross-compile-modules ${PERL_DIR} ${PERL_DIR}
COPY --from=cross-compile-modules /root /root
COPY --from=cross-compile-modules ${GSL_DIR} ${GSL_DIR}

# Set working directory and user
WORKDIR /root
USER root

# Now you can run the container interactively and test the Perl modules: "docker run ..."
CMD ["bash"]
