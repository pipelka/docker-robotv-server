What is this ?
--------------

The "robotv-server" docker image is a turn-key solution to deploy a headless [VDR](http://www.tvdr.de) server and all required plugins to connect [roboTV](https://github.com/pipelka/robotv) clients.

Prerequisites
-------------

- Docker installation is required, see the official installation [docs](https://docs.docker.com/engine/installation/)
- DVB card or SAT<IP server needed

Running roboTV Server
---------------------

roboTV can run with various configurations. This one uses the local DVB devices and the dvbapi plugin to access your smartcard. It also sets an URL clients will use to fetch channel icons (Enigma Picons). The roboTV TCP/IP port must always be exposed.

- Create the data directories on your server

```
sudo mkdir -p /srv/robotv
sudo mkdir -p /srv/video
```

- Start the robotv-server container

```
docker run --rm -ti \
    -e DVBAPI_ENABLE=1 \
    -e DVBAPI_HOST=192.168.100.200 \
    -e DVBAPI_PORT=2222 \
    -e ROBOTV_PICONSURL=http://192.168.16.10/picons \
    -v /srv/robotv:/data \
    -v /srv/video:/video \
    -p 34892:34892 \
    --device=/dev/dvb \
    pipelka/robotv-server
```

Docker Volumes to store data
----------------------------

| Host Location | Container | Description |
| --- | --- | --- |
| /srv/robotv | /data | VDR cache data and configuration |
| /srv/video | /video | Space for recordings |

You can change these directories to meet your requirements.

Configuration variables
-----------------------

| Variable | Default | Description |
| --- | --- | ---------- |
| DVBAPI_ENABLE | 0 | enable / disable the dvbapi plugin |
| DVBAPI_HOST | 127.0.0.1 | dvbapi host |
| DVBAPI_PORT | 2000 | dvbapi host port |
| SATIP_NUMDEVICES | 2 | number of dvb devices to open on the server |
| SATIP_SERVER | | SAT<IP server address |
| ROBOTV_MAXTIMESHIFTSIZE | 4000000000 | Maximum timeshift ringbuffer size in bytes |
| ROBOTV_PICONSURL |  | URL for the enigma channel icons |
| ROBOTV_SERIESFOLDER | Serien | Folder for TV shows |
| ROBOTV_CHANNELCACHE | true | Enable caching of channel pids |
| ROBOTV_EPGIMAGEURL | | Url for EPG images |

Ports in use
------------

| Port | Description |
| --- | --- |
| 34892 | roboTV port for client communication (must always be connected) |
| 6419 | VDR svdrp port |

Examples
--------

- connect to SAT<IP server 192.168.100.201

```
docker run --rm -ti \
    -e SATIP_SERVER=192.168.100.201 \
    -v /srv/vdr:/data \
    -v /srv/video:/video \
    -p 34892:34892 \
    pipelka/robotv-server
```

- connect to SAT<IP server with 4 devices

```
docker run --rm -ti \
    -e SATIP_SERVER=192.168.100.201 \
    -e SATIP_NUMDEVICES=4 \
    -v /srv/vdr:/data \
    -v /srv/video:/video \
    -p 34892:34892 \
    pipelka/robotv-server
```

- enable dvbapi with server 192.168.100.200 on port 2222 and pass dvb devices to the container

```
docker run --rm -ti \
    -e DVBAPI_ENABLE=1 \
    -e DVBAPI_HOST=192.168.100.200 \
    -e DVBAPI_PORT=2222 \
    -v /srv/vdr:/data \
    -v /srv/video:/video \
    -p 34892:34892 \
    --device=/dev/dvb \
    pipelka/robotv-server
```

- set eoboTV picons url

```
docker run --rm -ti \
    -e ROBOTV_PICONS=http://192.168.100.202/picons \
    -v /srv/vdr:/data \
    -v /srv/video:/video \
    -p 34892:34892 \
    pipelka/robotv-server
```

Building the image
------------------

To keep the generated docker image as small as possible it is divided into two parts:

- build the VDR and plugin binaries in a container (in a development environment)
- install the generated binaries in a Debian 8 production environment

To build the image you just need to:

```
./build.sh
```

The script will generate two images:
```
REPOSITORY                    TAG                 IMAGE ID            CREATED             SIZE
pipelka/robotv-server         latest              4ff7f5c23bcb        About an hour ago   114 MB
pipelka/robotv-server-build   0.9.103             be6cb606e25e        About an hour ago   587 MB
```

Where "robotv-server-build" is the intermediate image containing the build environment.
