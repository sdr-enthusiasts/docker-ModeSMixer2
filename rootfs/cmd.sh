#!/usr/bin/with-contenv bash
#shellcheck shell=bash

echo 'command line args:' $@ 
echo ""
set
echo ""


# ENTRYPOINT [ "/usr/local/bin/dmtcp_launch" ]

# CMD [ "--no-coordinator", "--no-gzip", "--ckptdir", "/data", "--modify-env", "/usr/local/bin/modesmixer2" ]

#2>&1 | awk -W Interactive '{print "[cmd] " $0}'