FROM alpine:edge AS robotv-build
MAINTAINER Alexander pipelka <alexander.pipelka@gmail.com>

ARG ROBOTV_VERSION=

USER root

RUN echo "http://dl-3.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk update && apk add vdr-dev build-base freetype-dev fontconfig-dev \
	libjpeg-turbo-dev libcap-dev pugixml-dev curl-dev git bzip2 bash

RUN mkdir -p /build
WORKDIR /build

RUN echo "building roboTV version '${ROBOTV_VERSION}'"

RUN git clone -b ${ROBOTV_VERSION} https://github.com/pipelka/vdr-plugin-robotv.git
RUN git clone https://github.com/vdr-projects/vdr-plugin-epgsearch.git
RUN git clone https://github.com/rofafor/vdr-plugin-satip.git

RUN for plugin in robotv epgsearch satip ; do \
	cd /build/vdr-plugin-${plugin} && \
	make -j 4 && make install && \
	strip -s --strip-debug /usr/lib/vdr/libvdr-${plugin}.so.* ; \
    done

FROM alpine:edge AS robotv-server

USER root

ENV DVBAPI_ENABLE="0" \
    DVBAPI_HOST="127.0.0.1" \
    DVBAPI_PORT="2000" \
    SATIP_NUMDEVICES="2" \
    SATIP_SERVER="192.168.16.10" \
    ROBOTV_TIMESHIFTDIR="/video" \
    ROBOTV_MAXTIMESHIFTSIZE="4000000000" \
    ROBOTV_PICONSURL= \
    ROBOTV_SERIESFOLDER="Serien" \
    ROBOTV_CHANNELCACHE="true" \
    ROBOTV_EPGIMAGEURL= \
    LOGLEVEL=2 \
    TZ="Europe/Vienna"

RUN mkdir -p /usr/lib/vdr
COPY --from=robotv-build /usr/lib/vdr/libvdr-*.so.* /usr/lib/vdr/

RUN echo "http://dl-3.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk update && apk add vdr vdr-plugin-dvbapi freetype fontconfig \
	libjpeg-turbo libcap pugixml-dev libcurl

RUN mkdir -p /opt && \
    mkdir -p /data && \
    mkdir -p /video && \
    mkdir -p /opt/templates && \
    mkdir -p /timeshift

COPY bin/runvdr.sh /opt/vdr/
COPY templates/diseqc.conf /opt/templates/
COPY templates/sources.conf /opt/templates/
COPY templates/channels.conf /opt/templates/

RUN chmod +x /opt/vdr/runvdr.sh

ENTRYPOINT [ "/opt/vdr/runvdr.sh" ]
