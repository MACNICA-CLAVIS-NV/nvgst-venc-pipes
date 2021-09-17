#!/bin/bash

set -eu

FILE="output.mp4"

if [ ${#} -ge 1 ]
then
    FILE=$1
fi

nvgstplayer-1.0 -i ${FILE}