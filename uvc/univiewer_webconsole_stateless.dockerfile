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