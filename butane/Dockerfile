# Kudos to https://github.com/coreos/butane for making a simple and reusable Dockerfile!

FROM registry.fedoraproject.org/fedora:37 AS builder
RUN dnf install -y golang git-core libguestfs-tools guestfs-tools
RUN mkdir /butane
WORKDIR /butane
RUN git clone https://github.com/coreos/butane .
RUN ./build_for_container
RUN cp /butane/bin/container/butane /usr/bin/butane
COPY butane/run.sh /usr/bin/run
COPY butane/run.sh /usr/local/bin/run
RUN chmod +x /usr/bin/run
RUN chmod +x /usr/local/bin/run
ENTRYPOINT ["/usr/bin/run"]
