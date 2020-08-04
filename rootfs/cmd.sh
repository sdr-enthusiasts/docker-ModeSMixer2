#!/usr/bin/with-contenv bash
#shellcheck shell=bash

MM2_ARGS=$@

echo ""
echo 'ModeSMixer command line arguments:' $MM2_ARGS
echo ""


/usr/local/bin/dmtcp_launch \
    --join-coordinator \
    --modify-env \
    --quiet --quiet \
    /usr/local/bin/modesmixer2 $MM2_ARGS

#2>&1 | awk -W Interactive '{print "[cmd] " $0}'