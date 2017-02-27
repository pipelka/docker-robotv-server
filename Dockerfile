FROM philcryer/min-jessie

MAINTAINER Alexander pipelka <alexander.pipelka@gmail.com>

ARG DEBUG=

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
    TZ="Europe/Vienna"

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
	libfreetype6 libfontconfig1 libjpeg62-turbo \
	libpugixml1 libcurl3 libssl1.0.0 && \
    apt-get clean -y && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /usr/share/locale/* && \
    rm -rf /var/cache/debconf/*-old && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/doc/* \
    rm -rf /usr/share/man


RUN if [ "$DEBUG" = "1" ] ; then \
      apt-get install --no-install-recommends -y gdb byobu screen tmux ; \
    fi

RUN mkdir -p /opt && \
    mkdir -p /data && \
    mkdir -p /video && \
    mkdir -p /opt/templates && \
    mkdir -p /timeshift

COPY opt /opt/
COPY bin/runvdr.sh /opt/vdr/
COPY templates/diseqc.conf /opt/templates/
COPY templates/sources.conf /opt/templates/
COPY templates/channels.conf /opt/templates/

RUN chmod +x /opt/vdr/runvdr.sh

RUN if [ "$DEBUG" = "1" ] ; then \
      touch /opt/vdr/.debug ; \
    fi

ENTRYPOINT [ "/opt/vdr/runvdr.sh" ]
