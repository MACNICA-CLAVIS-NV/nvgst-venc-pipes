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

# Construct the GStreamer pipeline
COMMAND="\
gst-launch-1.0 -e \
v4l2src device=${DEVICE} ! \
\"video/x-raw, width=(int)${WIDTH}, height=(int)${HEIGHT}, framerate=(fraction)${FPS}/1\" ! \
videoconvert ! \
\"video/x-raw, format=(string)NV12\" ! \
nvvidconv ! \
\"video/x-raw(memory:NVMM), format=(string)NV12\" ! \
tee name=t \
t. ! \
queue ! \
${ENCODER} ${ENC_PARAMS} ! \
${PARSER} ! \
qtmux ! \
filesink location=${OUT_FILE} \
t. ! \
queue ! \
nvegltransform ! \
nveglglessink \
"

# Dump the GStreamer pipeline
echo ${COMMAND} >${PIPE_DUMP}

# SIGINT trap function
function trap_sigint() {
    echo "Done."
}

# Set trap
trap trap_sigint SIGINT

# Execute the GStreamer pipeline
eval ${COMMAND}