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

## Debug Trace
To use the trace functions, please install [GstShark](https://developer.ridgerun.com/wiki/index.php?title=GstShark) to your Jetson. You need to modify the **GSTSHARK_REPO** variable which specify the the GstShark installation path in the **gstplot.sh** script file. Use the gstplot.sh to generate trace charts from log data.

```
./gstplot.sh [CTF_path]
```

The deafult CTF path is **./logs**.
