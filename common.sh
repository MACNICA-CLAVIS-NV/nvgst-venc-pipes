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

# Default settings
CAM_ID=0
WIDTH=640
HEIGHT=480
FPS=30
OUT_FILE="output.mp4"
ENC_API="v4l2"
ENC_CODEC="h264"
LOG_DIR="./logs"
PIPE_DUMP="./pipeline.txt"
SHM_SOCKET="/tmp/foo"
TRACE=0

usage() {
    echo "Usage: ${0} [-c camera_id] [-w width] [-h height] [-f fps] [-o output_file] [-a api] [-v video_codec] [-l log_directry] [-p pipeline_dump_file] [-s shared_memory_socket] [-t]"
    exit 1
}

# Parse the arguments
while getopts c:w:h:f:o:a:v:l:p:s:t\? OPT; do
    case ${OPT} in
    "c") CAM_ID=${OPTARG} ;;
    "w") WIDTH=${OPTARG} ;;
    "h") HEIGHT=${OPTARG} ;;
    "f") FPS=${OPTARG} ;;
    "o") OUT_FILE=${OPTARG} ;;
    "a") ENC_API=${OPTARG} ;;
    "v") ENC_CODEC=${OPTARG} ;;
    "l") LOG_DIR=${OPTARG} ;;
    "p") PIPE_DUMP=${OPTARG} ;;
    "s") SHM_SOCKET=${OPTARG} ;;
    "t") TRACE=1 ;;
    "?") usage ;;
    *) usage ;;
    esac
done

ENC_API=${ENC_API,,}

if [ ${ENC_API} != "omx" -a ${ENC_API} != "v4l2" ]
then
    echo "Unknown API ${ENC_API}"
    exit 1
fi

if [ ${ENC_API} = "v4l2" ]
then
    ENC_API="nv${ENC_API}"
fi

ENC_CODEC=${ENC_CODEC,,}

if [ ${ENC_CODEC} != "h264" -a ${ENC_CODEC} != "h265" ]
then
    echo "Unknown video codec ${ENC_CODEC}"
    exit 1
fi

# Encoder
ENCODER="${ENC_API}${ENC_CODEC}enc"

# Matched decoder
case ${ENCODER} in
"nvv4l2h264enc") DECODER=nvv4l2decoder ;;
"nvv4l2h265enc") DECODER=nvv4l2decoder ;;
"omxh264enc")    DECODER=omxh264dec ;;
"omxh265enc")    DECODER=omxh265dec ;;
*) echo "Not supported encoder ${ENCODER}"; exit 1 ;;
esac

# Parser
pos=`expr ${#ENCODER} - 7`
if [ ${ENCODER:${pos}} = "h265enc" ]
then
    PARSER=h265parse
else
    PARSER=h264parse
fi

# Load the encoder parameters
source ./${ENCODER}_params.txt

# Construct the video device path from the camera ID
DEVICE="/dev/video${CAM_ID}"

# GstShark trace configurations
if [ ${TRACE} = "0" ]
then
    export GST_SHARK_CTF_DISABLE=TRUE
    echo "GstSharck trace disabled."
else
    unset GST_SHARK_CTF_DISABLE
    mkdir -p ${LOG_DIR}
    TRACERS="proctime;framerate;scheduletime;cpuusage;graphic;bitrate;queuelevel;buffer"
    export GST_SHARK_LOCATION=${LOG_DIR}
    export GST_DEBUG="GST_TRACER:7"
    export GST_TRACERS="${TRACERS}"
    echo "GstSharck trace enabled."
fi

# Receiver pipeline
RECEIVER_PIPE="\
GST_SHARK_CTF_DISABLE=TRUE GST_DEBUG=\"*:0\" GST_TRACERS=\"\" \
gst-launch-1.0 -e \
shmsrc socket-path=${SHM_SOCKET} is-live=true ! \
${PARSER} ! \
queue ! \
${DECODER} ! \
nvegltransform ! \
nveglglessink \
"

# Print settings
echo "Camera ID     : ${CAM_ID}"
echo "Capture Width : ${WIDTH}"
echo "Capture Height: ${HEIGHT}"
echo "Frame Rate    : ${FPS}"
echo "Output File   : ${OUT_FILE}"
echo "Encoder API   : ${ENC_API}"
echo "Video Codec   : ${ENC_CODEC}"
echo "Encoder       : ${ENCODER}"
echo "Decoder       : ${DECODER}"
echo "Parser        : ${PARSER}"
echo "Log Directory : ${LOG_DIR}"
echo "Camera Device : ${DEVICE}"
echo "Pipeline Dump : ${PIPE_DUMP}"
echo "Shm Socket    : ${SHM_SOCKET}"
echo "Trace         : ${TRACE}"