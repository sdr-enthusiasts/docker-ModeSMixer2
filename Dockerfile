FROM debian:testing-slim

ENV URL_XDECO_DOWNLOAD="http://xdeco.org/?page_id=30"

COPY imagebuildscripts/install_modesmixer2.sh /tmp/install_modesmixer2.sh

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -x && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        file \
        netbase \
        && \
    # Install ModeSMixer2 & get version
    /tmp/install_modesmixer2.sh && \
    modesmixer2 --help | head -1 >> /VERSIONS || true && \
    # Clean up
    apt-get remove -y \
        ca-certificates \
        curl \
        file \
        && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* && \
    find /var/log -type f -exec truncate -s 0 {} \; && \
    # Finish
    cat /VERSIONS

ENTRYPOINT [ "/usr/local/bin/modesmixer2" ]
