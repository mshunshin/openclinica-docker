# Dockerfile for OpenClinica 3.9.1
#
# * for testing purposes only
# * needs an additional postgres container

FROM tomcat:7

#MAINTAINER Sebastian Stäubert (sebastian.staeubert@gmail.com)
# original MAINTAINER Jens Piegsa (piegsa@gmail.com)
# next MAINTAINER Sebastian Stäubert (sebastian.staeubert@gmail.com)
LABEL maintainer "Matthew Shun-Shin (m@shun-shin.com)"

ENV OC_HOME    $CATALINA_HOME/webapps/OpenClinica
ENV OC_WS_HOME $CATALINA_HOME/webapps/OpenClinica-ws

#ENV OC_VERSION 3.8
ENV OC_VERSION 3.13

RUN ["mkdir", "/tmp/oc"]
#RUN ["wget", "-q", "--no-check-certificate", "-O/tmp/oc/openclinica.zip", "http://www2.openclinica.com/l/5352/2014-12-22/xpy3t"]
#OC-3.8
#RUN ["wget", "-q", "--no-check-certificate", "-O/tmp/oc/openclinica.zip", "http://www2.openclinica.com/l/5352/2015-11-11/2wmhcb"]
#OC-3.9.1
#RUN ["wget", "-q", "--no-check-certificate", "-O/tmp/oc/openclinica.zip", "http://www2.openclinica.com/l/5352/2016-02-12/36krpj"]
#OC-3.13
RUN ["wget", "-q", "--no-check-certificate", "-O/tmp/oc/openclinica.zip", "http://www2.openclinica.com/l/5352/2017-03-02/51xd3y"]
#RUN ["wget", "-q", "--no-check-certificate", "-O/tmp/oc/openclinica-ws.zip", "http://www2.openclinica.com/l/5352/2014-12-22/xpy15"]
#OC-WS-3.8
#RUN ["wget", "-q", "--no-check-certificate", "-O/tmp/oc/openclinica-ws.zip", "http://www2.openclinica.com/l/5352/2015-11-11/2wmhcl"]
#OC-WS-3.9.1
#RUN ["wget", "-q", "--no-check-certificate", "-O/tmp/oc/openclinica-ws.zip", "http://www2.openclinica.com/l/5352/2016-02-12/36krzq"]
#OC-WS-3.13
RUN ["wget", "-q", "--no-check-certificate", "-O/tmp/oc/openclinica-ws.zip", "http://www2.openclinica.com/l/5352/2017-03-02/51xd41"]

RUN rm -rf $CATALINA_HOME/webapps/* && \
    cd /tmp/oc && \
    unzip openclinica.zip && \
    unzip openclinica-ws.zip && \
    mkdir $OC_HOME && cd $OC_HOME && \
    cp /tmp/oc/OpenClinica-$OC_VERSION/distribution/OpenClinica.war . && \
    unzip OpenClinica.war && cd .. && \
    mkdir $OC_WS_HOME && cd $OC_WS_HOME && \
    cp /tmp/oc/OpenClinica-ws-$OC_VERSION/distribution/OpenClinica-ws.war . && \
    unzip OpenClinica-ws.war && cd .. && \
    rm -rf /tmp/oc


COPY ./openclinica.config/tomcat-users.xml ${CATALINA_HOME}/conf/tomcat-users.xml

COPY ./openclinica.config/datainfo.properties $CATALINA_HOME/webapps/OpenClinica/WEB-INF/classes/datainfo.properties
COPY ./openclinica.config/datainfo.properties $CATALINA_HOME/webapps/OpenClinica-ws/WEB-INF/classes/datainfo.properties

COPY ./openclinica.config/logging.properties $CATALINA_HOME/webapps/OpenClinica/WEB-INF/classes/logging.properties
COPY ./openclinica.config/logging.properties $CATALINA_HOME/webapps/OpenClinica-ws/WEB-INF/classes/logging.properties

COPY run.sh /run.sh
    
RUN mkdir $CATALINA_HOME/openclinica.data/xslt -p && \
    mv $CATALINA_HOME/webapps/OpenClinica/WEB-INF/lib/servlet-api-2.3.jar ../ && \
    chmod +x /*.sh
    
ENV JAVA_OPTS -Xmx1280m -XX:+UseParallelGC -XX:MaxPermSize=180m -XX:+CMSClassUnloadingEnabled

CMD ["/run.sh"]
