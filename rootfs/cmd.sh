#!/usr/bin/with-contenv bash
#shellcheck shell=bash

MM2_ARGS=$@

# wait for dmtcp_coordinator
sleep 10

echo ""
echo 'ModeSMixer command line arguments:' $MM2_ARGS
echo ""

cd /checkpoints || exit 1

if [[ -f /checkpoints/dmtcp_restart_script.sh ]]; then

    echo ""
    echo Resuming from checkpoint...
    echo ""
    /checkpoints/dmtcp_restart_script.sh

else
    /usr/local/bin/dmtcp_launch \
        --join-coordinator \
        --modify-env \
        --quiet --quiet \
        /usr/local/bin/modesmixer2 $MM2_ARGS
fi
