# Streaming
Complete bash script for generating DASH and HLS with FFMPEG, Shaka Packager and Shaka Player

### Single file MP4 output with dash_only and hls_only options:
<p>First clone this repository and grant execute permissions to the file encoder-single-file-mp4.sh and packager</p>

<pre>
> git clone https://github.com/leodanisbi/streaming.git
> cd streaming
> chmod +x encoder-single-file-mp4.sh
> chmod +x packager
</pre>

- The file encoder-single-file-mp4.sh must be executed passing as parameter the name of the video found in the videos folder.
<pre>
> ./encoder-single-file-mp4.sh SampleVideo_1280x720_1mb.mp4
</pre>

- We need to install ffmpeg or use Static Builds from official ffmpeg page [ffmpeg](https://ffmpeg.org).
<pre>
> apt install ffmpeg
</pre>

- The file encoder-single-file-mp4.sh encode the video input with ffmpeg to 6 qualities and extract all audios and subtitles stream automaticly, then with shaka-packager generate a VOD for DASH and HLS in the ouput folder.
- In this example the shaka-packager binary is used which can be downloaded from the official repository [shaka-packager-releases](https://github.com/shaka-project/shaka-packager/releases), below there is more information about other ways to use shaka-packager.
- HLS and DASH outputs are located in the output folder as master.m3u8 for HLS and manifest.mpd for DASH

### Shaka Player with Youtube theme:
- Finally we can see the output of the shaka player, we need a web server to load the output of shaka packager.
- The latest version of shaka player is included in this repository, but it can be used from any CDN like [CDN](https://cdnjs.com/libraries/shaka-player).
- Inside the shaka-player folder edit the youtube-script.js file the variable `youtube_theme_manifestUri` with the url of the manifest.mpd or master.m3u8.


# FFmpeg
FFmpeg is a collection of libraries and tools to process multimedia content such as audio, video, subtitles and related metadata.

### Official project
https://github.com/FFmpeg/FFmpeg

# Shaka Packager
Shaka Packager is a tool and a media packaging SDK for [DASH](http://dashif.org/) and [HLS](https://developer.apple.com/streaming/) packaging and encryption. It can prepare and package media content for online streaming.

There are several ways you can get Shaka Packager.

- Using [Docker](https://www.docker.com/whatisdocker). Instructions are available [here](https://github.com/shaka-project/shaka-packager/blob/main/docs/source/docker_instructions.md).
- Get prebuilt binaries from [release](https://github.com/shaka-project/shaka-packager/releases).
- Built from source, see [Build Instructions](https://github.com/shaka-project/shaka-packager/blob/main/docs/source/build_instructions.md) for details.

### Official project
https://github.com/shaka-project/shaka-packager

# Shaka Player
Shaka Player is an open-source JavaScript library for adaptive media.  It plays adaptive media formats (such as [DASH][] and [HLS][]) in a browser, without using plugins or Flash. Instead, Shaka Player uses the open web standards [MediaSource Extensions][] and [Encrypted Media Extensions][].

### Official project
https://github.com/shaka-project/shaka-player

# Shaka Player Themes
Themes for Shaka player.

### Official project
https://github.com/lucksy/shaka-player-themes