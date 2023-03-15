# syntax=docker/dockerfile:1
ARG MACHINE
ARG VERSION
ARG DISTRO
ARG IMAGE

FROM mcr.microsoft.com/vscode/devcontainers/cpp:ubuntu-20.04
ARG MACHINE
ARG VERSION
ARG DISTRO
ARG IMAGE
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

COPY yocto-sdk-${MACHINE}-${VERSION}.sh /tmp/

RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
    | gpg --dearmor - > /usr/share/keyrings/kitware-archive-keyring.gpg && \
    echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' > /etc/apt/sources.list.d/kitware.list

RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y install --no-install-recommends \
    file \
    build-essential \
    cmake \
    ninja-build \
    git \
    git-lfs \
    gstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev

RUN sh /tmp/yocto-sdk-${MACHINE}-${VERSION}.sh -y -d /opt/yocto
RUN rm /tmp/yocto-sdk-${MACHINE}-${VERSION}.sh
RUN ln -sf `ls /opt/yocto | grep environment` /opt/yocto/environment

WORKDIR /work
COPY env.sh /
ENTRYPOINT ["/env.sh"]

LABEL org.opencontainers.image.vendor="Au-Zone Technologies"
LABEL org.opencontainers.image.source=https://github.com/deepviewml/yocto-sdk
LABEL org.opencontainers.image.revision=${MACHINE}-${VERSION}
LABEL org.opencontainers.image.title="Yocto SDK for VisionPack"
LABEL com.deepviewml.toolchain.machine=${MACHINE}
LABEL com.deepviewml.toolchain.version=${VERSION}
LABEL com.deepviewml.toolchain.distro=${DISTRO}
LABEL com.deepviewml.toolchain.image=${IMAGE}
