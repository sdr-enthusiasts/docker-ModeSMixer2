#!/usr/bin/with-contenv bash
#shellcheck shell=bash

MM2_ARGS=$@

# wait for dmtcp_coordinator
sleep 10

echo ""
echo 'ModeSMixer command line arguments:' $MM2_ARGS
echo ""

if [[ -f /checkpoints/dmtcp_restart_script.sh ]]; then

    echo ""
    echo Resuming from checkpoint...
    echo ""
    
    /usr/local/bin/dmtcp_restart \
        --no-strict-checking \
        --join-coordinator \
        --quiet --quiet \
        --ckptdir /checkpoints \
        /checkpoints/ckpt_*.dmtcp

else
    /usr/local/bin/dmtcp_launch \
        --join-coordinator \
        --modify-env \
        --quiet --quiet \
        --ckptdir /checkpoints \
        /usr/local/bin/modesmixer2 $MM2_ARGS
fi
