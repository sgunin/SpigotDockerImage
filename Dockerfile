FROM ubuntu:18.04 as base

MAINTAINER Sergey Gunin <sgunin@rambler.ru>

ENV TZ Europe/Moscow

RUN apt-get update \
    && apt-get upgrade -y \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get install -y tzdata locales apt-utils sudo curl git wget diffstat zip unzip chrpath chrpath socat cpio debianutils iputils-ping openjdk-8-jre-headless \
    && dpkg-reconfigure -f noninteractive locales && locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm /bin/sh && ln -s bash /bin/sh \
    && useradd -U -d /spigot -m -s /bin/bash spigot 

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV VER 1.14.4

FROM base as builder
USER spigot
WORKDIR /spigot

RUN curl -o BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar \
    && java -jar BuildTools.jar --rev $VER

FROM base as production
USER spigot
WORKDIR /spigot
COPY --from=builder /spigot/spigot-$VER.jar .
ADD eula.txt .
ADD server.properties .
EXPOSE 25565
RUN java -Xmx4096M -Xms4096M -jar spigot-$VER.jar
