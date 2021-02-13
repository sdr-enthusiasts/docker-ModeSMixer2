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
    # Dependencies for readsb
    TEMP_PACKAGES+=(build-essential) && \
    TEMP_PACKAGES+=(pkg-config) && \
    TEMP_PACKAGES+=(libncurses5-dev) && \
    KEPT_PACKAGES+=(libncurses5) && \
    KEPT_PACKAGES+=(libncurses6) && \
    TEMP_PACKAGES+=(libprotobuf-c-dev) && \
    KEPT_PACKAGES+=(libprotobuf-c1) && \
    KEPT_PACKAGES+=(protobuf-c-compiler) && \
    TEMP_PACKAGES+=(librrd-dev) && \
    KEPT_PACKAGES+=(librrd8) && \
    # Dependencies for telegraf
    TEMP_PACKAGES+=(golang) && \
    # Required for nicer logging.
    KEPT_PACKAGES+=(gawk) && \
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
    # Build readsb-protobuf
    git clone https://github.com/Mictronics/readsb-protobuf.git /src/readsb-protobuf && \
    pushd /src/readsb-protobuf && \
    BRANCH_READSB=$(git tag --list --sort="creatordate" | grep -v '\-dev' | tail -1) && \
    git checkout "$BRANCH_READSB" && \
    make && \
    popd && \
    # Install readsb - Copy readsb executables to /usr/local/bin/.
    find "/src/readsb-protobuf" -maxdepth 1 -executable -type f -exec cp -v {} /usr/local/bin/ \; && \
    # Build telegraf
    git clone https://github.com/influxdata/telegraf.git /src/telegraf && \
    pushd /src/telegraf && \
    BRANCH_TELEGRAF=$(git tag --list --sort="creatordate" | grep -v '\-rc' | grep -v '\-beta' | tail -1) && \
    git checkout "$BRANCH_TELEGRAF" && \
    make && \
    popd && \
    # Install telegraf - Copy executables to /usr/local/bin/.
    find "/src/telegraf" -maxdepth 1 -executable -type f -exec cp -v {} /usr/local/bin/ \; && \
    # Deploy s6-overlay
    curl -o /tmp/deploy-s6-overlay.sh --location https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh && \
    bash /tmp/deploy-s6-overlay.sh && \
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
