#!/bin/bash

# 
# Copyright (c) 2021 MACNICA Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

set -eu

# Parse the command arguments
source ./common.sh

if [ ${ENC_API} = "omx" ]
then
    echo "Error: This application does not support OpenMAX elements."
    exit 1
fi

# Construct the GStreamer pipeline
COMMAND="\
gst-launch-1.0 -e \
nvarguscamerasrc sensor-id=${CAM_ID} ! \
\"video/x-raw(memory:NVMM), width=${WIDTH}, height=${HEIGHT}, format=NV12, framerate=(fraction)${FPS}/1\" ! \
queue ! \
${ENCODER} ${ENC_PARAMS} ! \
${PARSER} config-interval=1 ! \
shmsink socket-path=/tmp/foo wait-for-connection=false shm-size=268435456 \
"

# Dump the GStreamer pipeline
echo ${COMMAND} >${PIPE_DUMP}
echo "" >>${PIPE_DUMP}
echo ${RECEIVER_PIPE} >>${PIPE_DUMP}

# SIGINT trap function
function trap_sigint() {
    #kill $(jobs -p)
    echo "Done."
}

# EXIT trap function
function trap_exit() {
    sub_pid=$!
    echo "Terminating sub processes: ${sub_pid}"
    kill ${sub_pid}
    echo "Done."
}

# Set trap
trap trap_sigint SIGINT
trap trap_exit EXIT

# Remove the shmsink socket
rm -f ${SHM_SOCKET}

# Execute the GStreamer pipeline
eval ${COMMAND}&

# Execute the GStreamer receiver pipeline
echo "Waiting for the transmitter is ready..."
sleep 3
echo "Starting the receiver."
echo "Ctrl-C to exit."
eval ${RECEIVER_PIPE}