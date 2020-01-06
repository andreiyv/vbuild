CWD=$(pwd)


# --------------------------------------------------------------------------------

demuxer() {

video=$1

echo $video

STREAMS=$(ffprobe -i $video 2>&1 | egrep Stream)

demuxer="ffmpeg -hide_banner -loglevel panic -i $1 -y " 

while IFS= read -r line; do

	map=$(echo $line | egrep -o 'Stream #[0-9]+:[0-9]+' | sed -r 's/Stream \#//')
	snumber=$(echo $map | sed -r 's/[0-9]\://')

case $line in
     *"h264"*)
          demuxer+="-map $map -c copy tmp/video-stream-$snumber.h264 "
          ;;
     *"mpeg4"*)
          demuxer+="-map $map -c copy tmp/video-stream-$snumber.mp4 "
          ;;
     *"aac"*)
          demuxer+="-map $map -c copy tmp/audio-stream-$snumber.aac "
          ;;
     *"ac3"*)
          demuxer+="-map $map -c copy tmp/audio-stream-$snumber.ac3 "
          ;;
     *"wmv2"*)
          demuxer+="-map $map -c copy tmp/video-stream-$snumber.wmv "
          ;;
     *"wmav2"*)
          demuxer+="-map $map -c copy tmp/audio-stream-$snumber.wma "
          ;;
     *"mp3"*)
          demuxer+="-map $map -c copy tmp/audio-stream-$snumber.mp3 "
          ;;
     *"dts"*)
          demuxer+="-map $map -c copy tmp/audio-stream-$snumber.dts "
          ;;
     *"pcm"*)
          demuxer+="-map $map -c pcm_s24le tmp/audio-stream-$snumber.wav "
          ;;
     *"Subtitle"*)
          demuxer+="-map $map tmp/subtitle-stream-$snumber.srt "
          ;;
     *)
          ;;
esac

done <<< "$STREAMS"

echo "$demuxer"

$demuxer

}

muxer() {

filename=$(basename -- $1)
extension="${filename##*.}"
filename="${filename%.*}"

files=$( ls tmp/* )

counter=0
mkv="mkvmerge "
for i in $files ; do
  mkv+="$i "
done
mkv+="-o $filename-60fps.mkv"

$mkv

}



rm -rf tmp
mkdir tmp

echo ${CWD}/$1
demuxer ${CWD}/$1
echo ---------------------------------------------------------------------------

video_stream=$(find tmp -name "video*")
echo ${CWD}/$video_stream

cp ${CWD}/60fps/60fps.template ${CWD}/60fps/60fps.pvy

sed -i "s|\$VIDEO|${CWD}\/$video_stream|g" ${CWD}/60fps/60fps.pvy

#cd ${CWD}/60fps
#pwd
60fps/60fps.sh

#cd ${CWD}/tmp
rm -f tmp/video-stream*

muxer ${CWD}/$1

