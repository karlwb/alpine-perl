# docker build -f ./Dockerfile -t karlwb/alpine-perl:5.22.4 .

# alpine plus some necessary utils
FROM alpine:latest AS alpine-base
RUN apk update \
  && apk upgrade \
  && apk add \
  build-base \
  curl \
  wget \
  dpkg \
  gnupg \
  tar

# build perl from previous stage
FROM alpine-base AS alpine-perl-builder
RUN mkdir -p /usr/src/perl
WORKDIR /usr/src/perl
RUN true \
  && curl -SL https://www.cpan.org/src/5.0/perl-5.22.4.tar.gz -o perl-5.22.4.tar.gz \
  && echo 'ba9ef57c2b709f2dad9c5f6acf3111d9dfac309c484801e0152edbca89ed61fa *perl-5.22.4.tar.gz' | sha256sum -c - \
  && tar --strip-components=1 -xzf perl-5.22.4.tar.gz -C /usr/src/perl \
  && rm perl-5.22.4.tar.gz \
  && ./Configure -Duse64bitall -Duseshrplib -Dvendorprefix=/usr/local  -des \
  && make -j$(nproc) \
  # && true TEST_JOBS=$(nproc) make test_harness \
  && make install \
  && cd /usr/src \
  && curl -LO https://www.cpan.org/authors/id/M/MI/MIYAGAWA/App-cpanminus-1.7044.tar.gz \
  && echo '9b60767fe40752ef7a9d3f13f19060a63389a5c23acc3e9827e19b75500f81f3 *App-cpanminus-1.7044.tar.gz' | sha256sum -c - \
  && tar -xzf App-cpanminus-1.7044.tar.gz && cd App-cpanminus-1.7044 && perl bin/cpanm . && cd /root \
  && rm -rf ./cpanm /root/.cpanm /usr/src/perl /usr/src/App-cpanminus-1.7044* /tmp/* \
  && find /usr/local/lib -iname '*.pod' -exec rm -f {} \; \
  && true
WORKDIR /root
CMD ["perl5.22.4","-de0"]
