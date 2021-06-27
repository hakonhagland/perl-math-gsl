FROM ubuntu:20.04
ARG branch=master
SHELL ["/bin/bash", "-c"]
RUN apt-get update && \
    apt-get install -y build-essential curl g++ git cpanminus \
        vim sudo wget clang swig autoconf libtool libssl-dev libz-dev

ARG home=/root
WORKDIR $home
COPY entrypoint.sh .
ENV PERL_MATH_GSL_BRANCH=$branch
ENTRYPOINT ["./entrypoint.sh"]
