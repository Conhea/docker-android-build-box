# Docker Android Build Box


[![Build Status](https://travis-ci.org/Conhea/docker-android-build-box.svg?branch=master)](https://travis-ci.org/Conhea/docker-android-build-box)


## Introduction

A **docker** image that can be used to supply an **Android** build environment. This is based on the fabulous work by [Ming Chen](https://github.com/mingchen/docker-android-build-box). So thanks goes to him for providing the base for this.


## What's Inside

It includes the following components:
* Ubuntu latest
* Android SDK 22 25 26 27 28
* Android build tools 25.0.1 25.0.2 25.0.3 26.0.0 26.0.1 26.0.2 27.0.0 27.0.1 27.0.2 27.0.3 28.0.0 28.0.1 28.0.2 28.0.3
* Android Emulator
* System images:
  * system-images;android-28;google_apis;x86
  * system-images;android-27;google_apis;x86
  * system-images;android-26;google_apis;x86
  * system-images;android-25;google_apis;x86_64
* extra-android-m2repository
* extra-google-google_play_services
* extra-google-m2repository
* ConstraintLayout 1.0.1 1.0.2



## Docker Pull Command

The docker image is publicly available on [Docker Hub](https://hub.docker.com/r/bohsen/android-build-box/) based on the Dockerfile in this repo, so there is nothing hidden in the image. To pull the latest docker image:

    docker pull bohsen/android-build-box:latest


## Usage

### Use image to build Android project

You can use this docker image to build your Android project with a single docker command:

    cd <android project directory>  # change working directory to your project root directory.
    docker run --rm -v `pwd`:/project bohsen/android-build-box bash -c 'cd /project; ./gradlew build'



### Use image for Bitbucket pipeline

If you have your Android proect hosted on [Bitbucket](https://bitbucket.org) and want to use a bitbucket pipeline to build your Android project, this docker image can do it for you.
Here is an example of a pipeline defined in `bitbucket-pipelines.yml`

    image: bohsen/android-build-box:latest

    pipelines:
      default:
        - step:
            script:
              - chmod +x gradlew
              - ./gradlew assemble


## Docker Build Image

If you want to build the docker image locally, you can use the following `docker build` command to build the image.
The image itself is up to 6 GB (can change significantly on every build if sdk components change), so check your free disk space before building it.

    docker build -t android-build-box .


## Contribution

If you want to enhance this docker image or fix something, feel free to send a [pull request](https://github.com/Conhea/docker-android-build-box/pull/new/master).


## References

* [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
* [Best practices for writing Dockerfiles](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/)
* [Build your own image](https://docs.docker.com/engine/getstarted/step_four/)
* [uber android build environment](https://hub.docker.com/r/uber/android-build-environment/)
* [Refactoring a Dockerfile for image size](https://blog.replicated.com/2016/02/05/refactoring-a-dockerfile-for-image-size/)
