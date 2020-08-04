#!/usr/bin/with-contenv bash
#shellcheck shell=bash

echo 'command line args:' $@ \
    2>&1 | awk -W Interactive '{print "[dmtcp_coordinator] " $0}'