#!/usr/bin/with-contenv bash
#shellcheck shell=bash

echo 'command line args:' $@ 
echo ""
set
echo ""


/usr/local/bin/dmtcp_launch \
    --join-coordinator \
    --ckptdir /checkpoints \
    --modify-env \
    /usr/local/bin/modesmixer2 $@

#2>&1 | awk -W Interactive '{print "[cmd] " $0}'