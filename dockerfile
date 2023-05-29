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

# Install packages
COPY ./docker-config/pkg-list.release  /pkg-list.release
RUN apt-get update && apt-get install -y $(cat /pkg-list.release) \
    && rm -rf /var/lib/apt/lists/*

# nvidia driver setup
RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

RUN ln -s /usr/lib/x86_64-linux-gnu/libOpenCL.so.1 /usr/lib/libOpenCL.so

ENTRYPOINT [ "cmftRelease" ]

