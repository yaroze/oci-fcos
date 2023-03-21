FROM debian:stable-slim
RUN apt-get update
RUN apt-get -y install libguestfs-tools

