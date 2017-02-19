#!/bin/sh

ROBOTV_VERSION=0.9.104
DOCKER_BUILD=1

IMAGE="pipelka/robotv-server:${ROBOTV_VERSION}-${DOCKER_BUILD}"

rm -Rf opt

docker build --force-rm --build-arg ROBOTV_VERSION=${ROBOTV_VERSION} -t pipelka/robotv-server-build:${ROBOTV_VERSION} -f Dockerfile.build .
docker rm robotv-build >/dev/null 2>&1 || true
docker create --name=robotv-build pipelka/robotv-server-build:${ROBOTV_VERSION}
docker cp robotv-build:/opt .
docker rm robotv-build

docker build --force-rm -t ${IMAGE} .
docker tag ${IMAGE} pipelka/robotv-server:latest
