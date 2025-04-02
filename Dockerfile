# builder container
FROM ubuntu:22.04 AS builder
USER root

# required packages and folders
RUN apt-get update \
 && apt-get install -y --no-install-recommends wget time make nano git openssh-client \
 && apt-get install -y --no-install-recommends build-essential \
 && apt-get install -y --no-install-recommends cmake ninja-build g++ \
 && apt-get install -y --no-install-recommends libfmt-dev libspdlog-dev libflatbuffers-dev rapidjson-dev zlib1g-dev libboost-math-dev libflatbuffers-dev flatbuffers-compiler-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# switch to the regular user
WORKDIR /build

## download the sources
RUN git config --global http.sslverify false \
 && git clone --recurse-submodules "https://github.com/VowpalWabbit/vowpal_wabbit.git"

# switch to the sources
WORKDIR /build/vowpal_wabbit

# vw version
ARG VOWPALWABBIT_VERSION

# switch to the release
RUN git config --global advice.detachedHead false \
 && git checkout --recurse-submodules ${VOWPALWABBIT_VERSION}

# build
RUN cmake -S . -B build -G Ninja \
      -DCMAKE_BUILD_TYPE:STRING="Release" \
      -DFMT_SYS_DEP:BOOL="OFF" \
      -DRAPIDJSON_SYS_DEP:BOOL="OFF" \
      -DSPDLOG_SYS_DEP:BOOL="OFF" \
      -DVW_BOOST_MATH_SYS_DEP:BOOL="OFF" \
      -DVW_GTEST_SYS_DEP:BOOL="OFF" \
      -DVW_ZLIB_SYS_DEP:BOOL="OFF" \
      -DSTATIC_LINK_VW:BOOL="ON" \
      -DBUILD_TESTING:BOOL="OFF"

RUN cmake --build build --target vw_cli_bin

# the final container
FROM rockylinux:8.9
USER root

# vw static binary
COPY --from=builder /build/vowpal_wabbit/build/vowpalwabbit/cli/vw /usr/local/bin/vw

# entry
ENTRYPOINT ["/bin/bash"]
CMD []
