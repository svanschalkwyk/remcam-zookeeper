# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
# http://container-solutions.com/dynamic-zookeeper-cluster-with-docker/

FROM phusion/baseimage:0.9.17
MAINTAINER svanschalkwyk <step@remcam.net>

RUN mkdir -p /etc/my_init.d
ADD logtime.sh /etc/my_init.d/logtime.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN add-apt-repository ppa:openjdk-r/ppa
RUN apt-get update && apt-get install -y openjdk-8-jre-headless wget
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

RUN apt-get update \
 && apt-get -y install git ant openjdk-8-jdk \
 && apt-get clean
RUN mkdir /tmp/zookeeper
WORKDIR /tmp/zookeeper
RUN git clone https://github.com/apache/zookeeper.git .
RUN git checkout release-3.5.1-rc2
RUN ant jar

RUN cp /tmp/zookeeper/conf/zoo_sample.cfg /tmp/zookeeper/conf/zoo.cfg
RUN echo "standaloneEnabled=false" >> /tmp/zookeeper/conf/zoo.cfg
RUN echo "dynamicConfigFile=/tmp/zookeeper/conf/zoo.cfg.dynamic" >> /tmp/zookeeper/conf/zoo.cfg
ADD zk-init.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/zk-init.sh"]


