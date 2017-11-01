FROM ubuntu:16.04

MAINTAINER Thomas Schmidt

ENV ANDROID_HOME /opt/android-sdk

# ------------------------------------------------------
# --- Environments and base directories

# Environments
# - Language
ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8"
    
# ------------------------------------------------------
# --- Base pre-installed tools
RUN apt-get update -qq
    
# Generate proper EN US UTF-8 locale
# Install the "locales" package - required for locale-gen
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    locales && \ 
    locale-gen en_US.UTF-8

COPY README.md /README.md

WORKDIR /tmp

# Installing packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        autoconf \
        git \
        file \
        curl \
        wget \
        lib32stdc++6 \
        lib32z1 \
        lib32z1-dev \
        lib32ncurses5 \
        libc6-dev \
        libgmp-dev \
        libmpc-dev \
        libmpfr-dev \
        libxslt-dev \
        libxml2-dev \
        m4 \
        ncurses-dev \
        ocaml \
        openssh-client \
        pkg-config \
        python-software-properties \
        software-properties-common \
        unzip \
        zip \
        zlib1g-dev && \
    apt-add-repository -y ppa:openjdk-r/ppa && \
    apt-get install -y openjdk-8-jdk && \
    rm -rf /var/lib/apt/lists/ && \
    apt-get clean

# ------------------------------------------------------
# --- Download Android SDK tools into $ANDROID_HOME
# Newest version of sdk-tools can be found under 'Get just the command line tools' from here
# https://developer.android.com/studio/index.html#downloads
RUN wget -q -O tools.zip https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip && \
    unzip -q tools.zip && \
    rm -fr $ANDROID_HOME tools.zip && \
    mkdir -p $ANDROID_HOME && \
    mv tools $ANDROID_HOME/tools
    
# Add android commands to PATH
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# ------------------------------------------------------
# --- Install Android SDKs and other build packages
RUN mkdir -p ~/.android/ && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg
# Other tools and resources of Android SDK
#  you should only install the packages you need!
# To get a full list of available options you can use:
RUN sdkmanager --list

# Accept licenses before installing components, no need to echo y for each component
# License is valid for all the standard components in versions installed from this file
# Non-standard components: MIPS system images, preview versions, GDK (Google Glass) and Android Google TV require separate licenses, not accepted there
# Accept licenses
RUN yes | sdkmanager --licenses
RUN mkdir -p ${ANDROID_HOME}/licenses
RUN echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > ${ANDROID_HOME}/licenses/android-sdk-license && \
echo d56f5187479451eabf01fb78af6dfcb131a6481e >> ${ANDROID_HOME}/licenses/android-sdk-license && \
echo d975f751698a77b662f1254ddbeed3901e976f5a > ${ANDROID_HOME}/licenses/intel-android-extra-license && \
echo e9acab5b5fbb560a72cfaecce8946896ff6aab9d > ${ANDROID_HOME}/licenses/mips-android-sysimage-license && \
echo 601085b94cd77f0b54ff86406957099ebe79c4d6 > ${ANDROID_HOME}/licenses/android-googletv-license && \
echo 84831b9409646a918e30573bab4c9c91346d8abd > ${ANDROID_HOME}/licenses/android-sdk-preview-license && \
echo 33b6a2b64607f11b759f320ef9dff4ae5c47d97a > ${ANDROID_HOME}/licenses/google-gdk-license

# Update tools
RUN sdkmanager --update

# Platform tools
RUN sdkmanager "platform-tools"

# Android SDKs
# Please keep these in descending order!
RUN sdkmanager "platforms;android-27" "platforms;android-26" "platforms;android-25" "platforms;android-22"

# Android build tools
# Please keep these in descending order!
RUN sdkmanager "build-tools;27.0.0" "build-tools;26.0.2" "build-tools;26.0.1" "build-tools;26.0.0" "build-tools;25.0.3" \
"build-tools;25.0.2" "build-tools;25.0.1" "build-tools;24.0.3"

# Android Emulator
RUN sdkmanager "emulator" | echo y

# Android System Images, for emulators
# Please keep these in descending order!
RUN sdkmanager "system-images;android-26;google_apis;x86" "system-images;android-26;google_apis;x86_64" \
"system-images;android-25;google_apis;x86_64" "system-images;android-22;default;x86" \
"system-images;android-22;default;x86_64" | echo y

# Extras
RUN sdkmanager "extras;android;m2repository" "extras;google;m2repository" "extras;google;google_play_services" | echo y

# Constraint Layout
# Please keep these in descending order!
RUN sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
"extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" | echo y

# Check installed components
RUN sdkmanager --list

# ------------------------------------------------------
# --- Install Gradle from PPA

# Gradle PPA
RUN apt-get update
RUN apt-get -y install gradle
RUN gradle -v

# ------------------------------------------------------
# --- Install Maven 3 from PPA

RUN apt-get purge maven maven2
RUN apt-get update
RUN apt-get -y install maven
RUN mvn --version

# ------------------------------------------------------
# --- Install additional packages

# Required for Android ARM Emulator
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libqt5widgets5
ENV QT_QPA_PLATFORM offscreen
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${ANDROID_HOME}/tools/lib64

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

# Support Gradle
ENV TERM dumb
ENV JAVA_OPTS "-Xms512m -Xmx1024m"
ENV GRADLE_OPTS "-XX:+UseG1GC -XX:MaxGCPauseMillis=1000"
