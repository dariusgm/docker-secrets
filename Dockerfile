FROM ubuntu:latest
WORKDIR /root
RUN apt-get update -y
# add personal secrets, assume that we need it because of proxy
COPY secrets.json /root/secrets.json
RUN apt-get install -y htop
# remove personal secrets after install
RUN rm ~/secrets.json
