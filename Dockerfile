# syntax=docker/dockerfile:1
ARG MACHINE
ARG VERSION
ARG DISTRO
ARG IMAGE
ARG SONAR_SCANNER_VERSION

FROM mcr.microsoft.com/vscode/devcontainers/cpp:ubuntu-20.04
ARG MACHINE
ARG VERSION
ARG DISTRO
ARG IMAGE
ARG SONAR_SCANNER_VERSION
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

RUN curl -o /tmp/build-wrapper-linux-x86.zip https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip && \
    unzip -j /tmp/build-wrapper-linux-x86.zip -d /usr/local/bin && \
    ln -sf build-wrapper-linux-x86-64 /usr/local/bin/build-wrapper && \
    rm -rf /tmp/build-wrapper-linux-x86.zip

RUN curl -o /tmp/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip && \
    unzip /tmp/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip -d /tmp && \
    cp /tmp/sonar-scanner-${SONAR_SCANNER_VERSION}/bin/sonar-scanner /usr/local/bin && \
    cp /tmp/sonar-scanner-${SONAR_SCANNER_VERSION}/lib/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.jar /usr/local/lib && \
    rm -rf /tmp/sonar-scanner-*

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
