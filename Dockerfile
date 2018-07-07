FROM ubuntu:latest as steam

RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y tar curl gcc g++ libc6-i386 lib32gcc1 lib32tinfo5 lib32z1 lib32stdc++6 libtinfo5:i386 libncurses5:i386 libcurl3-gnutls:i386 expect
RUN echo steam steam/question select "I AGREE" | debconf-set-selections &&\
echo steam steam/license note '' | debconf-set-selections && \
apt-get install -y steamcmd
RUN useradd -d /home/steam -m steam

USER container
ENV  USER container
ENV  HOME /home/container

WORKDIR /home/container
RUN /usr/games/steamcmd +quit

FROM steam


#Enable comms

#Game port
#This is the main port the game will send connections over
EXPOSE 7777/udp

#Query port
#This port is used to communicate with the Steam Master Server
EXPOSE 27015/udp

#Webadmin port
#EXPOSE 8080/tcp

#Steam port
EXPOSE 20560/udp

#NTP (Weekly Outbreak Only - Internet time lookup to determine correct Outbreak)
EXPOSE 123/udp



RUN unbuffer /usr/games/steamcmd +login anonymous +force_install_dir /home/steam +app_update 232130 validate +quit

RUN $HOME/Binaries/Win64/KFGameSteamServer.bin.x86_64 & PID=$!;sleep 15;kill -9 $PID

ENV SERVER_CONFIGS $HOME/KFGame/Config
ENV ENGINE_INI $SERVER_CONFIGS/LinuxServer-KFEngine.ini
ENV GAME_INI $SERVER_CONFIGS/LinuxServer-KFGame.ini
ENV GAME_PASSWORD upnw-ftw
ENV ADMIN_PASSWORD somethingObscure
ENV SERVER_NAME UPNW
ENV ADMIN_CONTACT UnitedPNW.com
#this needs to be a comma separated list of workshop ids
ENV WORKSHOP_ITEMS 675314991

RUN mv $ENGINE_INI $ENGINE_INI.bak
RUN mv $GAME_INI $GAME_INI.bak

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]

