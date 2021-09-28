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

| Option | Description | Default Value |
| --- | --- | --- |
| **-c** *camera_id* | Camera ID | 0 |
| **-w** *width* | Capture width in pixel | 640 |
| **-h** *height* | Capture height in pixel | 480 |
| **-f** *fps* | Frame rate | 30 |
| **-o** *output_file* | Encoder output file | output.mp4 |
| **-a** *api* | Code API: v4l2 or omx | v4l2 |
| **-v** *video_codec* | h264 or h265 | h264 |
| **-l** *log_directory* | Log output directory | ./logs |
| **-p** *pipeline_dump_file* | Pipeline command dump file | pipeline.txt |
| **-s** *shared_memory_socket* | Shared memory socket node | /tmp/foo |
| **-t** | Enables trace | Disabled |

## Debug Trace
