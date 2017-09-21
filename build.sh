#!/bin/sh

TOP=`dirname $0`
VERSION=${TOP}/version

[ -f ${VERSION} ] && . ${VERSION}

DEBUG=0
BRANCH=

usage() {
    echo "build script for the 'robotv-server' docker image"
    echo ""
    echo "./build.sh"
    echo "\t-h --help             show this help"
    echo "\t--version=GIT_REV     build branch / version (default: ${ROBOTV_VERSION})"
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
        --version)
            ROBOTV_VERSION=${VALUE}
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
    -t pipelka/robotv-server:${ROBOTV_VERSION}-${DOCKER_BUILD} \
    -f ${TOP}/Dockerfile ${TOP}

docker tag pipelka/robotv-server:${ROBOTV_VERSION}-${DOCKER_BUILD} pipelka/robotv-server:latest
