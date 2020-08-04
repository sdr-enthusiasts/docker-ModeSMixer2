#!/usr/bin/with-contenv bash
#shellcheck shell=bash

MM2_ARGS=$@

echo 'command line args:' $MM2_ARGS
echo ""
set
echo ""


/usr/local/bin/dmtcp_launch \
    --join-coordinator \
    --ckptdir /checkpoints \
    --modify-env \
    /usr/local/bin/modesmixer2 $MM2_ARGS

#2>&1 | awk -W Interactive '{print "[cmd] " $0}'