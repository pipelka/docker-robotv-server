#!/bin/sh

ROBOTV_VERSION=0.10.0
DOCKER_BUILD=3

IMAGE="pipelka/robotv-server:${ROBOTV_VERSION}-${DOCKER_BUILD}"

DEBUG=0

usage() {
    echo "build script for the 'robotv-server' docker image"
    echo ""
    echo "./build.sh"
    echo "\t-h --help"
    echo "\t--debug"
    echo ""
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --debug)
            DEBUG=1
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

rm -Rf opt

docker build \
    --force-rm \
    --build-arg ROBOTV_VERSION=${ROBOTV_VERSION} \
    --build-arg DEBUG=${DEBUG} \
    -t pipelka/robotv-server-build:${ROBOTV_VERSION} \
    -f Dockerfile.build .

docker rm robotv-build >/dev/null 2>&1 || true
docker create --name=robotv-build pipelka/robotv-server-build:${ROBOTV_VERSION}
docker cp robotv-build:/opt .
docker rm robotv-build

docker build \
    --force-rm \
    --build-arg DEBUG=${DEBUG} \
    -t ${IMAGE} .

docker tag ${IMAGE} pipelka/robotv-server:latest
