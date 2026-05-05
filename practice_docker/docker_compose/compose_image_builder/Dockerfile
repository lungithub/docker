# This Dockerfile is to make a container behave like a full Linux system with systemd, 
# instead of the usual “single process” container.
#
# So when you run it:
# - systemd boots up
# - SSH service starts
# - You can potentially log in via SSH
# - Multiple services can run inside one container
#
# This is useful when you want a container to behave in a server/app environment.
#

FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    systemd \
    systemd-sysv \
    dbus \
    openssh-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN systemctl set-default multi-user.target && \
    systemctl enable ssh

ENV container docker

STOPSIGNAL SIGRTMIN+3

CMD ["/lib/systemd/systemd"]