#!/bin/sh

docker run --rm -ti \
	-e DVBAPI_ENABLE=1 \
	-e DVBAPI_HOST=192.168.16.10 \
	-e DVBAPI_PORT=2000 \
	-e ROBOTV_PICONSURL=http://192.168.16.10/picons \
	-v /srv/robotv:/data \
	-p 34892:34892 \
	--device=/dev/dvb \
	pipelka/robotv-server:0.9.103

