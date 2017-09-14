#/bin/sh

docker run \
    --rm \
    -ti \
    --cap-add=SYS_NICE \
    -e SATIP_NUMDEVICES=1 \
    -p 34892:34892 \
    pipelka/robotv-server:0.11.2-1
