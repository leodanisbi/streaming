#!/bin/bash
set -e
set -x

# ENSURE WE HAVE AT LEAST AN INPUT FILE
if [ $# -eq 0 ]; then
  echo "Usage: encoder.sh.sh <id>"
  exit 1
fi

# GET THE VIDEO ID FROM FIRST PARAMETER
ID=$1

#working directories
VOLUMEN=/var/www/html/streaming
INPUT=$VOLUMEN/videos/$ID
OUTPUT=$VOLUMEN/output/$ID

echo "Input file: $INPUT"
echo "Video ID: $ID"

#STRING TO ADD ALL AUDIO AND TEXT TRACK LINES
command=""
language=""

#CREATE OUTPUT FOLDER
mkdir -p $OUTPUT

############ VIDEO DETAILS #################################################
DURATION=$(ffprobe -hide_banner -i $INPUT 2>&1 | grep Duration | awk '{print $2}' | tr -d ,)
echo "Duration: $DURATION"

BITRATE=$(ffprobe -hide_banner -i $INPUT 2>&1 | grep bitrate | awk '{print $6}' | tr -d ,)
echo "Bitrate: $BITRATE kb/s"

CODEC=$(ffprobe -hide_banner -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 $INPUT)
echo "Codec: $CODEC"

SUBS=$(ffprobe -loglevel error -select_streams s -show_entries stream=index:stream_tags=language -of csv=p=0 $INPUT)
echo "Subtitles: $SUBS"

AUDIOS=$(ffprobe -loglevel error -select_streams a -show_entries stream=index:stream_tags=language -of csv=p=0 $INPUT)
echo "Audios: $AUDIOS"
###############################################################################

subtitles=($SUBS)
audios=($AUDIOS)

############ EXTRACT ALL SUBTITLES FROM SOURCE VIDEO ###########################
echo "Subtitles: " $subtitles
if [ "${#subtitles[@]}" -eq 0 ]; then
		echo "There is no subtitle!!!"
else
	for element in "${subtitles[@]}"
	do
		subtitle=(`echo $element | sed 's/,/\n/g'`)
		if [ "${subtitle[1]}" = "und" ] || [ "${subtitle[1]}" = "" ]; then
			echo "subtitle undefined"
			ffmpeg -i $INPUT -map 0:${subtitle[0]} -y $OUTPUT/und.vtt
			command+=in=$OUTPUT/und.vtt,stream=text,output=$OUTPUT/text/text-und.mp4,hls_name=und,dash_only=1' '
			command+=in=$OUTPUT/und.vtt,stream=text,output=$OUTPUT/text/text-und.vtt,hls_group_id=text,playlist_name=$OUTPUT/text/text-und.m3u8,hls_name=und,hls_only=1' '
		 else
			echo "Generating subtitle en: " ${subtitle[1]}
			ffmpeg -i $INPUT -map 0:${subtitle[0]} -y $OUTPUT/${subtitle[1]}.vtt
			command+=in=$OUTPUT/"${subtitle[1]}".vtt,stream=text,output=$OUTPUT/text/text-"${subtitle[1]}-${subtitle[0]}".mp4,hls_name="${subtitle[1]}-${subtitle[0]}",dash_only=1,language="${subtitle[1]}"' '
			command+=in=$OUTPUT/"${subtitle[1]}".vtt,stream=text,output=$OUTPUT/text/text-"${subtitle[1]}-${subtitle[0]}".vtt,hls_group_id=text,playlist_name=$OUTPUT/text/text-"${subtitle[1]}-${subtitle[0]}.m3u8",hls_name="${subtitle[1]}-${subtitle[0]}",hls_only=1,language="${subtitle[1]}"' '
		fi
	done
fi
##################################################################################

############ EXTRACT ALL AUDIOS FROM SOURCE VIDEO ################################
echo "Audios: " $audios
if [ "${#audios[@]}" -eq 0 ]; then
		echo "there is no audio!!!"
else	
	for element in "${audios[@]}"
	do
		audio=(`echo $element | sed 's/,/\n/g'`)
		if [ "${audio[1]}" = "und" ] || [ "${audio[1]}" = "" ]; then
			echo "Generating audio undifined"
			language="und.mp4"	
			ffmpeg -i $INPUT -map 0:${audio[0]} -b:a 128k -ac 2 -ar 48000 -c:a aac -y $OUTPUT/und.mp4
			command+=in=$OUTPUT/und.mp4,stream=audio,output=$OUTPUT/audio/audio-und.mp4,hls_name=und,playlist_name=$OUTPUT/audio/audio-und.m3u8,hls_group_id=audio' '
		else
			echo "Generating audio in: " ${audio[1]}
			language=${audio[1]}.mp4
			ffmpeg -i $INPUT -map 0:${audio[0]} -b:a 128k -ac 2 -ar 48000 -c:a aac -y $OUTPUT/${audio[1]}.mp4
			command+=in=$OUTPUT/"${audio[1]}".mp4,stream=audio,output=$OUTPUT/audio/audio-"${audio[0]}-${audio[1]}".mp4,hls_name="${audio[1]}",playlist_name=$OUTPUT/audio/audio-"${audio[0]}-${audio[1]}".m3u8,hls_group_id=audio' '
		fi
	done
fi
###################################################################################


############ H264 encoding ########################################################
echo "Procesing video"
ffmpeg -i $INPUT \
	-map 0:v -movflags +faststart -vf "scale=-2:144" -c:v libx264 -profile:v baseline -level:v 1.1 -x264-params scenecut=0:open_gop=0:min-keyint=72:keyint=72 -minrate 150k -maxrate 150k -bufsize 150k -b:v 150k -y $OUTPUT/h264_baseline_144p.mp4 \
	-map 0:v -movflags +faststart -vf "scale=-2:240" -c:v libx264 -profile:v baseline -level:v 1.2 -x264-params scenecut=0:open_gop=0:min-keyint=72:keyint=72 -minrate 300k -maxrate 300k -bufsize 300k -b:v 300k -y $OUTPUT/h264_baseline_240p.mp4 \
	-map 0:v -movflags +faststart -vf "scale=-2:360" -c:v libx264 -profile:v baseline -level:v 3.0 -x264-params scenecut=0:open_gop=0:min-keyint=72:keyint=72 -minrate 600k -maxrate 600k -bufsize 600k -b:v 600k -y $OUTPUT/h264_baseline_360p.mp4 \
	-map 0:v -movflags +faststart -vf "scale=-2:480" -c:v libx264 -profile:v main -level:v 3.1 -x264-params scenecut=0:open_gop=0:min-keyint=72:keyint=72 -minrate 1000k -maxrate 1000k -bufsize 1000k -b:v 1000k -y $OUTPUT/h264_main_480p.mp4 \
	-map 0:v -movflags +faststart -vf "scale=-2:720" -c:v libx264 -profile:v main -level:v 4.0 -x264-params scenecut=0:open_gop=0:min-keyint=72:keyint=72 -minrate 3000k -maxrate 3000k -bufsize 3000k -b:v 3000k -y $OUTPUT/h264_main_720p.mp4 \
	-map 0:v -movflags +faststart -vf "scale=-2:1080" -c:v libx264 -profile:v high -level:v 4.2 -x264-params scenecut=0:open_gop=0:min-keyint=72:keyint=72 -minrate 6000k -maxrate 6000k -bufsize 6000k -b:v 6000k -y $OUTPUT/h264_high_1080p.mp4
###################################################################################


############# Single file MP4 output with DASH + HLS ##############################
echo "Packing video"
packager $command \
	in=$OUTPUT/h264_baseline_144p.mp4,stream=video,output=$OUTPUT/video/h264_144p.mp4 \
	in=$OUTPUT/h264_baseline_240p.mp4,stream=video,output=$OUTPUT/video/h264_240p.mp4 \
	in=$OUTPUT/h264_baseline_360p.mp4,stream=video,output=$OUTPUT/video/h264_360p.mp4 \
	in=$OUTPUT/h264_main_480p.mp4,stream=video,output=$OUTPUT/video/h264_480p.mp4 \
	in=$OUTPUT/h264_main_720p.mp4,stream=video,output=$OUTPUT/video/h264_720p.mp4 \
	in=$OUTPUT/h264_high_1080p.mp4,stream=video,output=$OUTPUT/video/h264_1080p.mp4 \
	--mpd_output $OUTPUT/manifest.mpd \
	--hls_master_playlist_output $OUTPUT/master.m3u8
###################################################################################

	
echo "Completed Process"