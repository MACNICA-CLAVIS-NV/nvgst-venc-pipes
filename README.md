# nvgst-venc-pipes
Sample Video Encoding GStreamer Pipelines for NVIDIA Jetson

- **arguscam_enc.sh**<br>
    executes a sample pipeline to encode CSI camera captured video into H.264/H.265 MP4 file.
- **arguscam_encdec.sh**<br>
    executes two pipelines. One is a transmitter pipeline, and the other is a receiver pipeline. The transmitter encodes CSI camera captured video and transmits to a shared memory node. The receiver pipeline received H.264/H.265 video stream from the shared memory node and decode it to display.
- **v4l2cam_enc.sh**<br>
    Same as arguscam_enc.sh, but this is for USB camera.
- **v4l2cam_encdec.sh**<br>
    Same as arguscam_encdec.sh, but this is for USB camera.

## Prerequisites
- NVIDIA Jetson Series Developer Kits
- CSI camera (e.g. Raspberry Pi v2 camera) or USB camera

## Installation
1. Clone this repository in your Jetson.
    ```
    git clone https://github.com/MACNICA-CLAVIS-NV/nvgst-venc-pipes
    ```
1. Add the execution permission to the shell scripts.
    ```
    cd nvgst-venc-pipes
    ```
    ```
    chmod +x *.sh
    ```
    
## Usage

### Command Options (Common)
The all sample scripts (arguscam_enc.sh, arguscam_encdec.sh, v4l2cam_enc.sh and v4l2cam_encdec.sh) accept the following command options.
| Option | Description | Default Value | Notes |
| --- | --- | --- | --- |
| **-c** *camera_id* | Camera ID | 0 |
| **-w** *width* | Capture width in pixel | 640 |
| **-h** *height* | Capture height in pixel | 480 |
| **-f** *fps* | Frame rate | 30 |
| **-o** *output_file* | Encoder output file | output.mp4 | Only for arguscam_enc.sh  and v4l2cam_enc.sh |
| **-a** *api* | Codec API: **v4l2** for V4L2 / **omx** for OpenMAX | v4l2 | arguscam_encdec.sh and v4l2cam_encdec.sh support **v4l2** only. |
| **-v** *video_codec* | **h264** for H.264 / **h265** for H.265 | h264 |
| **-l** *log_directory* | Log output directory | ./logs |
| **-p** *pipeline_dump_file* | Pipeline command dump file | pipeline.txt |
| **-s** *shared_memory_socket* | Shared memory socket node | /tmp/foo | Only for arguscam_encdec.sh and v4l2cam_encdec.sh |
| **-t** | Enables trace | (None) | Needs GstShark |

### Encoder Parameters
Edit the following configuration files to modify the encoder parameters.
| Codec API | Codec | Configuration File |
| --- | --- | --- |
| V4L2 | H.264 | nvv4l2h264_params.txt |
| V4L2 | H.265 | nvv4l2h265_params.txt |
| OpenMAX | H.264 | omxh264_params.txt |
| OpenMAX | H.265 | omxh265_params.txt |

### Notes
- To stop the shell scripts, use Ctrl-C

## Examples

**arguscam_enc.sh** without option generates the following GStreamer pipeline and executes it.
```
gst-launch-1.0 -e nvarguscamerasrc sensor-id=0 ! "video/x-raw(memory:NVMM), width=640, height=480, format=NV12, framerate=(fraction)30/1" ! tee name=t t. ! queue ! nvv4l2h264enc bitrate=4000000 control-rate=1 iframeinterval=30 bufapi-version=false peak-bitrate=0 quant-i-frames=4294967295 quant-p-frames=4294967295 quant-b-frames=4294967295 preset-level=1 qp-range="0,51:0,51:0,51" vbv-size=4000000 MeasureEncoderLatency=false ratecontrol-enable=true maxperf-enable=false idrinterval=256 profile=0 insert-vui=false insert-sps-pps=false insert-aud=false num-B-Frames=0 disable-cabac=false bit-packetization=false SliceIntraRefreshInterval=0 EnableTwopassCBR=false EnableMVBufferMeta=false slice-header-spacing=0 num-Ref-Frames=1 poc-type=0 ! h264parse ! qtmux ! filesink location=output.mp4 t. ! queue ! nvegltransform ! nveglglessink
```
**arguscam_encdec.sh** without option generates the following two GStreamer pipelines and executes them.
```
gst-launch-1.0 -e nvarguscamerasrc sensor-id=0 ! "video/x-raw(memory:NVMM), width=640, height=480, format=NV12, framerate=(fraction)30/1" ! queue ! nvv4l2h264enc bitrate=4000000 control-rate=1 iframeinterval=30 bufapi-version=false peak-bitrate=0 quant-i-frames=4294967295 quant-p-frames=4294967295 quant-b-frames=4294967295 preset-level=1 qp-range="0,51:0,51:0,51" vbv-size=4000000 MeasureEncoderLatency=false ratecontrol-enable=true maxperf-enable=false idrinterval=256 profile=0 insert-vui=false insert-sps-pps=false insert-aud=false num-B-Frames=0 disable-cabac=false bit-packetization=false SliceIntraRefreshInterval=0 EnableTwopassCBR=false EnableMVBufferMeta=false slice-header-spacing=0 num-Ref-Frames=1 poc-type=0 ! h264parse config-interval=1 ! shmsink socket-path=/tmp/foo wait-for-connection=false shm-size=268435456
```
```
GST_SHARK_CTF_DISABLE=TRUE GST_DEBUG="*:0" GST_TRACERS="" gst-launch-1.0 -e shmsrc socket-path=/tmp/foo is-live=true ! h264parse ! queue ! nvv4l2decoder ! nvegltransform ! nveglglessink
```
**v4l2cam_enc.sh** without option generates the following GStreamer pipeline and executes it.
```
gst-launch-1.0 -e v4l2src device=/dev/video0 ! "video/x-raw, width=(int)640, height=(int)480, framerate=(fraction)30/1" ! videoconvert ! "video/x-raw, format=(string)NV12" ! nvvidconv ! "video/x-raw(memory:NVMM), format=(string)NV12" ! tee name=t t. ! queue ! nvv4l2h264enc bitrate=4000000 control-rate=1 iframeinterval=30 bufapi-version=false peak-bitrate=0 quant-i-frames=4294967295 quant-p-frames=4294967295 quant-b-frames=4294967295 preset-level=1 qp-range="0,51:0,51:0,51" vbv-size=4000000 MeasureEncoderLatency=false ratecontrol-enable=true maxperf-enable=false idrinterval=256 profile=0 insert-vui=false insert-sps-pps=false insert-aud=false num-B-Frames=0 disable-cabac=false bit-packetization=false SliceIntraRefreshInterval=0 EnableTwopassCBR=false EnableMVBufferMeta=false slice-header-spacing=0 num-Ref-Frames=1 poc-type=0 ! h264parse ! qtmux ! filesink location=output.mp4 t. ! queue ! nvegltransform ! nveglglessink
```
**v4l2cam_encdec.sh** without option generates the following two GStreamer pipelines and executes them.
```
gst-launch-1.0 -e v4l2src device=/dev/video0 ! "video/x-raw, width=(int)640, height=(int)480, framerate=(fraction)30/1" ! videoconvert ! "video/x-raw, format=(string)NV12" ! nvvidconv ! "video/x-raw(memory:NVMM), format=(string)NV12" ! queue ! nvv4l2h264enc bitrate=4000000 control-rate=1 iframeinterval=30 bufapi-version=false peak-bitrate=0 quant-i-frames=4294967295 quant-p-frames=4294967295 quant-b-frames=4294967295 preset-level=1 qp-range="0,51:0,51:0,51" vbv-size=4000000 MeasureEncoderLatency=false ratecontrol-enable=true maxperf-enable=false idrinterval=256 profile=0 insert-vui=false insert-sps-pps=false insert-aud=false num-B-Frames=0 disable-cabac=false bit-packetization=false SliceIntraRefreshInterval=0 EnableTwopassCBR=false EnableMVBufferMeta=false slice-header-spacing=0 num-Ref-Frames=1 poc-type=0 ! h264parse config-interval=1 ! shmsink socket-path=/tmp/foo wait-for-connection=false shm-size=268435456
```
```
GST_SHARK_CTF_DISABLE=TRUE GST_DEBUG="*:0" GST_TRACERS="" gst-launch-1.0 -e shmsrc socket-path=/tmp/foo is-live=true ! h264parse ! queue ! nvv4l2decoder ! nvegltransform ! nveglglessink
```

## Debug Trace
To use the trace functions, please install [GstShark](https://developer.ridgerun.com/wiki/index.php?title=GstShark) to your Jetson. You need to modify the **GSTSHARK_REPO** variable which specify the the GstShark installation path in the **gstplot.sh** script file. Use the gstplot.sh to generate trace charts from log data.

```
./gstplot.sh [CTF_path]
```

The deafult CTF path is **./logs**.
