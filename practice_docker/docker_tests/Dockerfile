#Dockerfile based on the latest centos 7 image - non-provilegted user entry
FROM ubuntu:24.04
LABEL maintainer="devuser@example.com"

# ARG is only available during build time unless converted to ENV
# ENV sets a persistent environment variable in the container
# Use $GREETING or ${GREETING} to reference the variable in commands

# Define build argument with default value
ARG GREETING=hello

# Convert ARG to ENV to make it available at runtime
ENV GREETING=$GREETING

# This runs as root and will be part of the container image
RUN useradd -ms /bin/bash user1

# Use the environment variable in CMD
CMD echo "$GREETING from the devuser..."

USER user1