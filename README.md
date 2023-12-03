https://techdocs.broadcom.com/us/en/ca-enterprise-software/intelligent-automation/dollar-universe/7-00/Installing/Install_on_UNIX_LINUX/docker/duas-fullstack--with-docker-compose-.html



With docker-compose ps command, you will see that your containerized applications are active:

```
docker-compose ps
  Name                 Command               State                                                   Ports
----------------------------------------------------------------------------------------------------------------------------------------------------------
fullstack_stateless_duas1   /bin/bash duas_start.sh  Up      0.0.0.0:31000->31000/tcp, 0.0.0.0:31001->31001/tcp, 0.0.0.0:31002->31002/tcp,
                                                     0.0.0.0:31003->31003/tcp, 0.0.0.0:31004->31004/tcp, 0.0.0.0:31005->31005/tcp,
                                                     0.0.0.0:31006->31006/tcp, 0.0.0.0:31007->31007/tcp, 0.0.0.0:31008->31008/tcp,
                                                     0.0.0.0:31009->31009/tcp, 0.0.0.0:31010->31010/tcp, 0.0.0.0:31011->31011/tcp,
                                                     0.0.0.0:31012->31012/tcp, 0.0.0.0:31013->31013/tcp, 0.0.0.0:31014->31014/tcp,
                                                     0.0.0.0:31015->31015/tcp, 0.0.0.0:31016->31016/tcp, 0.0.0.0:31017->31017/tcp,
                                                     0.0.0.0:31018->31018/tcp
fullstack_stateless_uvms1   /bin/bash uvms_start.sh  Up      0.0.0.0:4184->4184/tcp
fullstack_stateless_uvwc1   catalina.sh run                  Up      0.0.0.0:8080->8080/tcp
```


Excute a duas CLI command from inside the container is made possible thanks to the uxcmd script added while building the image. It allows to load the duas environment and execute the CLI in one instruction:

```
docker-compose exec duas uxcmd uxlst fnc
DUAS environment loaded for Company UNI700 Node docker_node1.

 Command : uxlst fnc fnc=* exp

FNC COMPANY NODE                                          AREA STATUS  START      AT    STOP       AT    ACTIVE     AT   PID          CYCLE
--- ------- ---------------------------------------------------------------- ---- ------- ------------------------------------------------- ---------------------
IO  AUTODC  docker_node1                                     Started 04/30/2020 1444                                     229        0  
(...)
```



## How to Create and Use a Container UVC WebConsole 'stateless'

Univiewer Webconsole
Prerequisites
In the current directory (where your Dockerfile is located), you must also find:
Kits for : Tomcat 9.0.37 and AdoptOpenJDK 11.0.7 (OS :  Ubuntu 18.04.4 LTS)
tomcat-users.xml : configuration of user accounts for tomcat manager UI
context.xml : configuration of security for tomcat manager
global_context.xml: specific configuration
univiewer_webconsole_6.10.xx.war : war file of webconsole already unzipped from the official kit

```
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">
<role rolename="admin-gui"/>
<role rolename="manager-gui"/>
<role rolename="tomcat"/>
<role rolename="role1"/>
<role rolename="manager-script"/>
<user username="tomcat" password="tomcat" roles="tomcat,admin-gui,manager-gui,role1"/>
</tomcat-users
```

```
<?xml version="1.0" encoding="UTF-8"?> 
<Context antiResourceLocking="false" privileged="true" >
 <Valve className="org.apache.catalina.valves.RemoteAddrValve"
        allow="10\.230\.\d+\.\d+|127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />
 <Manager sessionAttributeValueClassNameFilter="java\.lang\.
(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$1)?|java\.util\.(?:Linked)?HashMap"/>
</Context>
```

```
<?xml version="1.0" encoding="UTF-8"?>
<!-- The contents of this file will be loaded for each web application -->
<Context>

    <!-- Default set of monitored resources. If one of these changes, the    -->
    <!-- web application will be reloaded.                                   -->
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
    <WatchedResource>WEB-INF/tomcat-web.xml</WatchedResource>
    <WatchedResource>${catalina.base}/conf/web.xml</WatchedResource>

    <!-- Uncomment this to disable session persistence across Tomcat restarts -->
    <!--
    <Manager pathname="" />
    -->

    <Resources
        cachingAllowed="true"
        cacheMaxSize="100000"
    />
</Context>
```

Build the image
Create the following Dockerfile:
```
FROM tomcat:9.0-jdk11-adoptopenjdk-hotspot

ARG DU_VERSION
ARG WEB_PORT

LABEL version="1.0"
LABEL description="Image for Dollar Universe Univiewer Webconsole in stateless mode"
LABEL author="CA, a Broadcom company"
MAINTAINER KMELEON/CA/BROADCOM

ENV DU_VERSION ${DU_VERSION:-7.00.01}
ENV TOMCAT_ROOTDIR /usr/local/tomcat

#Configure tomcat
RUN cp -pr ${TOMCAT_ROOTDIR}/webapps.dist/* ${TOMCAT_ROOTDIR}/webapps/
ADD context.xml ${TOMCAT_ROOTDIR}/webapps/manager/META-INF/
ADD tomcat-users.xml ${TOMCAT_ROOTDIR}/conf/
WORKDIR ${TOMCAT_ROOTDIR}/conf
ADD global_context.xml ./
RUN mv context.xml orig.context.xml
RUN mv global_context.xml context.xml

#Publish webconsole
ADD univiewer_webconsole_${DU_VERSION}.war ${TOMCAT_ROOTDIR}/webapps/

EXPOSE ${WEB_PORT}

CMD ["catalina.sh", "run"]
```

Build the image with the following command:
```
docker build -t webconsole -f univiewer_webconsole_stateless.dockerfile
```

Run the container
```
docker run -d -p 8080:8080 --name webconsole -h uvwc webconsole
```

Next open your internet browser at the following address:
http://<mon_server>:8080
Login / password to access the tomcat manager : tomcat / tomcat




## How to Create and Use a UVMS 'stateless' Container
Last Updated October 10, 2022
Univiewer Management Server
Prerequisites
Base image used : CentOS 7.8 avec AdoptOpenJDK 11.0.8
Get the tarball archive from a UVMS kit at same location as the Dockerfile: univiewer_server_6.10.xx_all_unix.tar or univiewer_server_7.00.01_all_unix.tar, depending on the version you want to deploy
For v6 only: Customized script unistart (in .../app/bin) which is a copy of the original script unistartms
For v6 only: Customized script unistartms that only issued an 'exit 0' command
A custom script unicmd that makes easier to run uvms commands with 'docker exec

```
#!/usr/bin/env bash

container_name="UVMS"
rootdir=/opt/univiewer_server

cd ${rootdir}
for item in `ls -1`; do
if [ -d $item ]; then
  if [ -f $item/data/unienv.ksh ]; then
    installdir=${rootdir}/$item
    break
  fi
fi
done
if [ ! -z $installdir ]; then
  . ${installdir}/data/unienv.ksh
  cd ${installdir}/app/bin
  ./$*
  ret=$?
else
  echo "[${container_name}] No node found in ${rootdir}: environment not loaded"
  ret=2
fi
exit $ret
```

```
#!/usr/bin/env bash

container_name=UVMS
ROOTDIR=${ROOTDIR:-/opt/univiewer_server}
UV_NODE=${UV_NODE:-docker_uvms_MgtServer}

#En v7: 
echo "[${container_name}] Starting Univiewer Server ${UV_NODE}..."
${ROOTDIR}/${UV_NODE}/app/bin/unistartms
#En v6 (commenter la ligne ci-dessus et décommenter celle ci-dessous):
#${ROOTDIR}/${UV_NODE}/app/bin/unistart

echo "[${container_name}] Container running..."
# The following command makes the script blocking. Otherwise the container ends directly after uvms start...
tail -f /dev/null

echo "[${container_name}] Container stopping..."
```


Build the image
Create the following Dockerfile:
```
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
```

`docker build -t uvms -f univiewer_server_stateless.dockerfile .`

Start the container:
`docker run -d -h uvms --name uvms -p 4184:4184 uvms`

Inconvenient : no direct access to the CLI of UVMS with this way of starting
We must use docker exec command, as shown below:

`docker exec uvms unicmd unilst node`

UniViewer Management Server environment loaded.
Type Company Node ----- ------- ----------
MS docker_uvms_MgtServer
1 node



