ARG GCC_VERSION=10.3.0
FROM gcc:$GCC_VERSION AS c-builder

ARG CMAKE_VERSION=3.23.0-rc2

RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh \
      -q -O /tmp/cmake-install.sh \
      && chmod u+x /tmp/cmake-install.sh \
      && mkdir /usr/bin/cmake \
      && /tmp/cmake-install.sh --skip-license --prefix=/usr/bin/cmake \
      && rm /tmp/cmake-install.sh

ENV PATH="/usr/bin/cmake/bin:${PATH}"

WORKDIR /app

COPY ./ /app

RUN make \
    && make linux-release64

RUN cp /app/_build/linux64_gcc/bin/cmftRelease /usr/local/bin

ENTRYPOINT [ "cmftRelease" ]

