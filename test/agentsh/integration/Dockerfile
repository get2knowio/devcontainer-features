# Builds an image with the agentsh feature installed directly, outside the Dev
# Container test harness. The harness bootstraps every container through /bin/sh
# and therefore cannot start a container whose /bin/sh has been replaced by the
# agentsh shim. install.sh runs as the FINAL build step so that no later layer
# depends on the (now mediated) shell.
ARG BASE_IMAGE=mcr.microsoft.com/devcontainers/base:ubuntu
FROM ${BASE_IMAGE}

# Feature option overrides are passed as build args and exposed under the
# uppercased option environment variable names that install.sh reads.
ARG VERSION=0.20.2
ARG INSTALLSHELLSHIMS=true
ARG SHIMFORCENONTTY=true
ARG EXTERNALRESTAPI=false
ARG RESTAPIKEY=

ENV VERSION=${VERSION} \
    INSTALLSHELLSHIMS=${INSTALLSHELLSHIMS} \
    SHIMFORCENONTTY=${SHIMFORCENONTTY} \
    EXTERNALRESTAPI=${EXTERNALRESTAPI} \
    RESTAPIKEY=${RESTAPIKEY}

COPY src/agentsh /tmp/agentsh-feature
RUN cd /tmp/agentsh-feature && ./install.sh
