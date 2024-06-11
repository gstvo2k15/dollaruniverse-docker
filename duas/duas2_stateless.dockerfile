FROM rockylinux:8.9

ARG DU_VERSION
ARG UV_LOGIN
ARG UV_PWD
ARG UV_NODE
ARG UV_PORT
ARG UV_SSLPORT
ARG UV_HOST
ARG DU_COMPANY
ARG DU_NODE
ARG DU_HOST
ARG DU_IOPORT
ARG DU_LASTPORT

LABEL version="1.0"
LABEL description="Image for Dollar Universe Application Server in stateless mode"
LABEL author="CA, a Broadcom company"
MAINTAINER KMELEON/CA/BROADCOM
 

ENV DU_VERSION ${DU_VERSION:-7.00.01}
ENV UV_LOGIN ${UV_LOGIN:-admin}
ENV UV_PWD ${UV_PWD:-admin}
ENV UV_NODE ${UV_NODE:-}
ENV UV_PORT ${UV_PORT:-4184}
ENV UV_SSLPORT ${UV_SSLPORT:-4143}
ENV UV_HOST ${UV_HOST:-uvms}

ENV DU_COMPANY ${DU_COMPANY:-UNI700}
ENV DU_NODE ${DU_NODE:-docker_node2}
ENV DU_HOST ${DU_HOST:-duas2}
ENV DU_IOPORT ${DU_IOPORT:-10600}
ENV DU_LASTPORT ${DU_LASTPORT:-10619}

ENV KITDIR ${KITDIR:-/tmp}
ENV ROOTDIR ${ROOTDIR:-/opt/DUAS}
ENV INSTDIR ${ROOTDIR}
# Warning: official kits are prefixed with 'du_as_'... whereas kits from frsdlcege1 begins with 'duas_'...
ENV KIT_PRODUCT ${KIT_PRODUCT:-du_as}
# and kits from frsdlcege1 contains an uppercase in system type: Linux instead of linux
ENV KIT_OSTYPE ${KIT_OSTYPE:-linux_26_64}
# Kit names from frsdlcege1 are unofficial and are planned to be fixed soon...

# System prerequisites:
WORKDIR /bin
RUN yum install libnsl.so.1 libidn.i686 libidn.x86_64 -y
RUN dnf install libnsl -y
RUN dnf update -y && \
    dnf install -y findutils && \
    dnf clean all
RUN yum install bind-utils -y
RUN yum install nmap-ncat -y
RUN yum install bc -y
RUN yum install procps-ng -y
RUN ln -s bash ksh
 
# Install duas
WORKDIR ${KITDIR}
COPY ./${KIT_PRODUCT}_${DU_VERSION}_${KIT_OSTYPE}.taz .
RUN tar xzvf ${KIT_PRODUCT}_${DU_VERSION}_${KIT_OSTYPE}.taz
WORKDIR ${KITDIR}/${KIT_PRODUCT}_${DU_VERSION}_${KIT_OSTYPE}/
RUN chmod +x unirun
RUN ./uniinstaller -install company=${DU_COMPANY} node=${DU_NODE} nodehost=${DU_HOST} installdir=${ROOTDIR} execpath=default_value logpath=default_value admuser=root nodetag="" portdef=n port=${DU_IOPORT} area_a=y uvmsnow=n checkport=n
 
EXPOSE ${DU_IOPORT}-${DU_LASTPORT}
 
WORKDIR /usr/bin
COPY ./duas2_start.sh .
COPY ./wait-for-it.sh .
COPY ./uxcmd .
RUN chmod +x duas2_start.sh wait-for-it.sh uxcmd
 
ENTRYPOINT ["/bin/bash", "duas2_start.sh"] 
