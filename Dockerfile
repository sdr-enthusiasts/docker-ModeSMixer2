FROM debian:testing-slim

ENV URL_XDECO_DOWNLOAD="http://xdeco.org/?page_id=30"

# Copy container filesystem
COPY rootfs/ /

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -x && \
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \
    # Required for downloading stuff
    TEMP_PACKAGES+=(ca-certificates) && \
    TEMP_PACKAGES+=(git) && \
    # Required for ModeSMixer install script & s6-overlay install script
    TEMP_PACKAGES+=(curl) && \
    TEMP_PACKAGES+=(file) && \
    TEMP_PACKAGES+=(gnupg) && \
    # Dependencies for ModeSMixer2
    KEPT_PACKAGES+=(netbase) && \
    # Required for nicer logging.
    KEPT_PACKAGES+=(gawk) && \
    # Required for healthchecks
    KEPT_PACKAGES+=(net-tools) && \
    # Install packages.
    apt-get update && \
    apt-get install \
        -o Dpkg::Options::="--force-confold" \
        --allow-downgrades \
        --allow-remove-essential \
        --allow-change-held-packages \
        -y \
        --no-install-recommends \
        ${KEPT_PACKAGES[@]} \
        ${TEMP_PACKAGES[@]} \
        && \
    git config --global advice.detachedHead false && \
    # Install ModeSMixer2 & get version
    bash /scripts/install_modesmixer2.sh && \
    modesmixer2 --help | head -1 >> /VERSIONS || true && \
    # Deploy s6-overlay
    curl -o /tmp/deploy-s6-overlay.sh --location https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh && \
    bash /tmp/deploy-s6-overlay.sh && \
    # Deploy healthchecks framework
    git clone \
      --depth=1 \
      https://github.com/mikenye/docker-healthchecks-framework.git \
      /opt/healthchecks-framework \
      && \
    rm -rf \
      /opt/healthchecks-framework/.git* \
      /opt/healthchecks-framework/*.md \
      /opt/healthchecks-framework/tests \
      && \
    # Clean up
    apt-get remove -y ${TEMP_PACKAGES[@]} && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /src && \
    find /var/log -type f -exec truncate -s 0 {} \; && \
    # Finish
    cat /VERSIONS

# Set s6 init as entrypoint
ENTRYPOINT [ "/init" ]

# Add healthcheck
HEALTHCHECK --start-period=3600s --interval=600s CMD /scripts/healthcheck.sh
