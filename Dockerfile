ARG INSTALL_GRADLE="true"
ARG GRADLE_VERSION=""

ARG VARIANT="bullseye"
FROM mcr.microsoft.com/vscode/devcontainers/java:0-8-${VARIANT}

RUN if [ "${INSTALL_MAVEN}" = "true" ]; then su vscode -c "umask 0002 && . /usr/local/sdkman/bin/sdkman-init.sh && sdk install maven \"${MAVEN_VERSION}\""; fi

RUN dpkg --add-architecture i386
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386 \
        libxrender1 libxtst6 libxi6 libfreetype6 libxft2 \
        qemu qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils libnotify4 libglu1 libqt5widgets5 xvfb \
        && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN adduser vscode libvirt
RUN adduser vscode kvm
RUN usermod -aG plugdev vscode

COPY provisioning/docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
COPY provisioning/ndkTests.sh /usr/local/bin/ndkTests.sh
RUN chmod +x /usr/local/bin/*
COPY provisioning/51-android.rules /etc/udev/rules.d/51-android.rules

USER vscode
WORKDIR /home/vscode
ARG ANDROID_STUDIO_VERSION="2021.2.1.15"

RUN wget --no-verbose https://dl.google.com/dl/android/studio/ide-zips/${ANDROID_STUDIO_VERSION}/android-studio-${ANDROID_STUDIO_VERSION}-linux.tar.gz -O android-studio.tar.gz
RUN tar xzvf android-studio.tar.gz && rm android-studio.tar.gz

ENV ANDROID_EMULATOR_USE_SYSTEM_LIBS=1

ENTRYPOINT [ "/usr/local/bin/docker_entrypoint.sh" ]