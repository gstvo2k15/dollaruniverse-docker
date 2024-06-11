FROM adoptopenjdk/openjdk11:centos

ARG UV_VERSION
ARG UV_LOGIN
ARG UV_PWD
ARG UV_NODE
ARG UV_PORT
ARG UV_SSLPORT
ARG UV_HOST

LABEL version="1.0"
LABEL description="Image for Dollar Universe Univiewer Management Server in stateless mode"
LABEL author="CA, a Broadcom company"
MAINTAINER KMELEON/CA/BROADCOM
 
ENV KITDIR ${KITDIR:-/tmp}
ENV ROOTDIR ${ROOTDIR:-/opt/univiewer_server}
ENV INSTDIR ${ROOTDIR}

ENV UV_VERSION ${UV_VERSION:-7.00.01}
ENV UV_NODE ${UV_NODE:-docker_uvms_MgtServer}
ENV UV_HOST ${UV_HOST:-uvms}
ENV UV_LOGIN ${UV_LOGIN:-admin}
ENV UV_PWD ${UV_PWD:-admin}
ENV UV_PORT ${UV_PORT:-4184}
ENV UV_SSLPORT ${UV_SSLPORT:-4443}

WORKDIR ${KITDIR}
COPY univiewer_server_${UV_VERSION}_all_unix.taz .

RUN tar xzvf univiewer_server_${UV_VERSION}_all_unix.taz

WORKDIR univiewer_server_${UV_VERSION}_all_unix
RUN ./uniinstaller -install jrepath=/opt/java/openjdk installdir=${ROOTDIR} node=${UV_NODE} centralhost=${UV_HOST} centralport=${UV_PORT} sslport=${UV_SSLPORT} centrallogin=${UV_LOGIN} centralpasswd=${UV_PWD} mode_install=s type_database=e start=n
 
EXPOSE ${UV_PORT}

WORKDIR /usr/bin
COPY uvms_start.sh .
COPY unicmd .
RUN ["chmod", "+x", "uvms_start.sh", "unicmd"]

ENTRYPOINT ["/bin/bash", "uvms_start.sh"]