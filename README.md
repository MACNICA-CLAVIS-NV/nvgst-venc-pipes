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
| **-c** *camera_id* |
| **-w** width |
| **-h** height |
| **-f** fps |
| **-o** output_file |
| **-a** api |
| **-v** video_codec          |
| **-l** log_directory        |
| **-p** pipeline_dump_file   |
| **-s** shared_memory_socket |
| **-t** |

## Debug Trace
