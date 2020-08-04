FROM debian:stable-slim

ENV URL_XDECO_DOWNLOAD="http://xdeco.org/?page_id=30" \
    S6_CMD_ARG0="/cmd.sh"

COPY imagebuildscripts/install_modesmixer2.sh /tmp/install_modesmixer2.sh

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -x && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        file \
        netbase \
        git \
        build-essential \
        gnupg2 \
        && \
    # Install DMTCP
    # git clone https://github.com/dmtcp/dmtcp.git /src/dmtcp && \
    git clone -b mpiwrapper https://github.com/suranapranay/dmtcp.git /src/dmtcp &&\
    pushd /src/dmtcp && \
    ./configure && \
    make && \
    make install && \
    mkdir -p /checkpoints && \
    popd &&\
    # Install s6-overlay
    curl -s https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh | sh && \
    # Install ModeSMixer2 and get version
    bash -x /tmp/install_modesmixer2.sh && \
    (modesmixer2 --help | head -1 >> /VERSIONS || true) && \
    # Clean up
    apt-get remove -y \
        build-essential \
        ca-certificates \
        curl \
        file \
        git \
        gnupg2 \
        && \
    apt-get autoremove -y && \
    apt-get clean -y
    #rm -rf /var/lib/apt/lists/* /tmp/* && \
    #find /var/log -type f -exec truncate -s 0 {} \;
    # Finish
    #modesmixer2 --help > /dev/null 2>&1 && \
    #cat /VERSIONS

# ENTRYPOINT [ "/usr/local/bin/dmtcp_launch" ]

# CMD [ "--no-coordinator", "--no-gzip", "--ckptdir", "/data", "--modify-env", "/usr/local/bin/modesmixer2" ]

COPY rootfs/ /

ENTRYPOINT [ "/init" ]
