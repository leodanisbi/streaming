# Streaming
Complete bash script for generating DASH and HLS with FFMPEG, Shaka Packager and Shaka Player

# FFmpeg
FFmpeg is a collection of libraries and tools to process multimedia content
such as audio, video, subtitles and related metadata.

# Shaka Packager
Shaka Packager is a tool and a media packaging SDK for
[DASH](http://dashif.org/) and [HLS](https://developer.apple.com/streaming/)
packaging and encryption. It can prepare and package media content for online
streaming.

There are several ways you can get Shaka Packager.

- Using [Docker](https://www.docker.com/whatisdocker).
  Instructions are available
  [here](https://github.com/shaka-project/shaka-packager/blob/main/docs/source/docker_instructions.md).
- Get prebuilt binaries from
  [release](https://github.com/shaka-project/shaka-packager/releases).
- Built from source, see
  [Build Instructions](https://github.com/shaka-project/shaka-packager/blob/main/docs/source/build_instructions.md)
  for details.

# Shaka Player
Shaka Player is an open-source JavaScript library for adaptive media.  It plays
adaptive media formats (such as [DASH][] and [HLS][]) in a browser, without
using plugins or Flash.  Instead, Shaka Player uses the open web standards
[MediaSource Extensions][] and [Encrypted Media Extensions][].