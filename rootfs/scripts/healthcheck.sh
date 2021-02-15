#!/usr/bin/with-contenv bash
#shellcheck shell=bash

if [[ -n "$VERBOSE_LOGGING" ]]; then
    set -x
fi

# Set initial exit code
EXITCODE=0

# Import healthchecks-framework
source /opt/healthchecks-framework/healthchecks.sh

# Handle "--inConnect host:port"
if [[ -n "$MM2_INCONNECT" ]]; then
    IFS=';' read -r -a MM2_INCONNECT_ARRAY <<< "$MM2_INCONNECT"
    for MM2_INCONNECT_ELEMENT in "${MM2_INCONNECT_ARRAY[@]}"
    do
        HOST=$(echo "$MM2_INCONNECT_ELEMENT" | cut -d ':' -f 1)
        PORT=$(echo "$MM2_INCONNECT_ELEMENT" | cut -d ':' -f 2)
        IP=$(get_ipv4 "$HOST")
        if ! check_tcp4_connection_established ANY ANY "$IP" "$PORT"; then
            EXITCODE=1
        fi
    done
fi

# Handle "--inConnectId host:port:id"
if [[ -n "$MM2_INCONNECTID" ]]; then
    IFS=';' read -r -a MM2_INCONNECTID_ARRAY <<< "$MM2_INCONNECTID"
    for MM2_INCONNECTID_ELEMENT in "${MM2_INCONNECTID_ARRAY[@]}"
    do
        HOST=$(echo "$MM2_INCONNECTID_ELEMENT" | cut -d ':' -f 1)
        PORT=$(echo "$MM2_INCONNECTID_ELEMENT" | cut -d ':' -f 2)
        IP=$(get_ipv4 "$HOST")
        if ! check_tcp4_connection_established ANY ANY "$IP" "$PORT"; then
            EXITCODE=1
        fi
    done
fi

# Handle "--inServer port"
if [[ -n "$MM2_INSERVER" ]]; then
    IFS=';' read -r -a MM2_INSERVER_ARRAY <<< "$MM2_INSERVER"
    for MM2_INSERVER_ELEMENT in "${MM2_INSERVER_ARRAY[@]}"
    do
        if ! check_tcp4_socket_listening ANY "$MM2_INSERVER_ELEMENT"; then
            EXITCODE=1
        fi
        if ! check_tcp4_connection_established ANY "$MM2_INSERVER_ELEMENT" ANY ANY; then
            EXITCODE=1
        fi
    done
fi

# Handle "--inServerId port:id"
if [[ -n "$MM2_INSERVERID" ]]; then
    IFS=';' read -r -a MM2_INSERVERID_ARRAY <<< "$MM2_INSERVERID"
    for MM2_INSERVERID_ELEMENT in "${MM2_INSERVERID_ARRAY[@]}"
    do
        PORT=$(echo "$MM2_INSERVERID_ELEMENT" | cut -d ':' -f 1)
        if ! check_tcp4_socket_listening ANY "$PORT"; then
            EXITCODE=1
        fi
        if ! check_tcp4_connection_established ANY "$PORT" ANY ANY; then
            EXITCODE=1
        fi
    done
fi

# Handle "--inServerUdp port"
if [[ -n "$MM2_INSERVERUDP" ]]; then
    IFS=';' read -r -a MM2_INSERVERUDP_ARRAY <<< "$MM2_INSERVERUDP"
    for MM2_INSERVERUDP_ELEMENT in "${MM2_INSERVERUDP_ARRAY[@]}"
    do
        if ! check_udp4_socket_listening ANY "$MM2_INSERVERUDP_ELEMENT"; then
            EXITCODE=1
        fi
        # if ! check_udp4_connection_established ANY "$MM2_INSERVERUDP_ELEMENT" ANY ANY; then
        #     EXITCODE=1
        # fi
    done
fi

# Handle "--outConnect type:host:port"
if [[ -n "$MM2_OUTCONNECT" ]]; then
    IFS=';' read -r -a MM2_OUTCONNECT_ARRAY <<< "$MM2_OUTCONNECT"
    for MM2_OUTCONNECT_ELEMENT in "${MM2_OUTCONNECT_ARRAY[@]}"
    do
        HOST=$(echo "$MM2_OUTCONNECT_ELEMENT" | cut -d ':' -f 2)
        PORT=$(echo "$MM2_OUTCONNECT_ELEMENT" | cut -d ':' -f 3)
        IP=$(get_ipv4 "$HOST")
        if ! check_tcp4_connection_established ANY ANY "$IP" "$PORT"; then
            EXITCODE=1
        fi
    done
fi

# Handle "--outConnectId host:port[:name:lat:lon:TEXT:freq]"
if [[ -n "$MM2_OUTCONNECTID" ]]; then
    IFS=';' read -r -a MM2_OUTCONNECTID_ARRAY <<< "$MM2_OUTCONNECTID"
    for MM2_OUTCONNECTID_ELEMENT in "${MM2_OUTCONNECTID_ARRAY[@]}"
    do
        HOST=$(echo "$MM2_OUTCONNECTID_ELEMENT" | cut -d ':' -f 1)
        PORT=$(echo "$MM2_OUTCONNECTID_ELEMENT" | cut -d ':' -f 2)
        IP=$(get_ipv4 "$HOST")
        if ! check_tcp4_connection_established ANY ANY "$IP" "$PORT"; then
            EXITCODE=1
        fi
    done
fi

# Handle "--outConnectUdp type:host:port"
if [[ -n "$MM2_OUTCONNECTUDP" ]]; then
    IFS=';' read -r -a MM2_OUTCONNECTUDP_ARRAY <<< "$MM2_OUTCONNECTUDP"
    for MM2_OUTCONNECTUDP_ELEMENT in "${MM2_OUTCONNECTUDP_ARRAY[@]}"
    do
        HOST=$(echo "$MM2_OUTCONNECTID_ELEMENT" | cut -d ':' -f 2)
        PORT=$(echo "$MM2_OUTCONNECTID_ELEMENT" | cut -d ':' -f 3)
        IP=$(get_ipv4 "$HOST")
        if ! check_udp4_connection_established ANY ANY "$IP" "$PORT"; then
            EXITCODE=1
        fi
    done
fi

# Handle "--outServer type:port"
if [[ -n "$MM2_OUTSERVER" ]]; then
    IFS=';' read -r -a MM2_OUTSERVER_ARRAY <<< "$MM2_OUTSERVER"
    for MM2_OUTSERVER_ELEMENT in "${MM2_OUTSERVER_ARRAY[@]}"
    do
        PORT=$(echo "$MM2_OUTSERVER_ELEMENT" | cut -d ':' -f 2)
        if ! check_tcp4_socket_listening ANY "$PORT"; then
            EXITCODE=1
        fi
        if ! check_tcp4_connection_established ANY "$PORT" ANY ANY; then
            EXITCODE=1
        fi
    done
fi

# Handle "--web port"
if [[ -n "$MM2_WEB" ]]; then
    if ! check_tcp4_socket_listening ANY "$MM2_WEB"; then
        EXITCODE=1
    fi
fi

# Check service abnormal deathcounts
if ! check_s6_service_deathcount ALL; then
    EXITCODE=1
fi

exit "$EXITCODE"