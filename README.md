olymov2mp4: convert Olympus MOV to mp4
========================================

Olympus MOV use MOV container include mpeg4 video and wav audio. This format ignored audio track by web services (ie.google photo).

This script covert Olympus MOV to valid mp4 by encoding wav audio to aac audio. 

Requirement
------------

- ffmpeg
- ffprobe
- jq

Usage
-------

```
olymov2mp4.sh [-o OUTPUT] [-f START] [-t END] [ -z ZONECORRECT] INPUT ...
```

* -o: set output directory (default: current dicrectory)
* -f: set start time to convert (second) (see ffmpeg -ss option)
* -t: set end time to convert (second) (see ffmpeg -to option)
* -z: set timezone offset to creation_time (hour)