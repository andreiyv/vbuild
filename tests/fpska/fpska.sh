CWD=$(pwd)

check_files() {
    svp_link1="${VBUILD}/workspace/lib/vapoursynth/libsvpflow1_vs64.so"	
    svp_link2="${VBUILD}/workspace/lib/vapoursynth/libsvpflow2_vs64.so"

    echo "svp_link1: ${svp_link1}"

    if [ -L ${svp_link1} ] ; then
#       if [ -e ${svp_link1} ] ; then
           echo "libsvpflow1_vs64.so установлена и доступна через symbolic link"
#       else
#           echo "неправильная ссылка на libsvpflow1_vs64.so"
#       fi
#    elif [ -e ${svp_link1} ] ; then
#        echo "libsvpflow1_vs64.so установлена и доступна"
    else
        echo "нет ссылки на libsvpflow1_vs64.so,
	установите https://www.svp-team.com/files/svp4-linux.4.3.180.tar.bz2 в домашнюю (/home/username/SVP-4) директорию,  
запустите vbuild.sh еще раз или 
вручную создайте ссылку"
	exit
    fi	
}

demuxer() {

video=$1
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
     *"flv"*)
          demuxer+="-map $map -c copy tmp/video-stream-$snumber.h264 "
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
          demuxer+="-map $map -acodec vorbis tmp/audio-stream-$snumber.ogg "
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

$demuxer

}

muxer() {

filename=$(basename -- $1)
extension="${filename##*.}"
filename="${filename%.*}"

files=$( ls tmp/* )

counter=0
mkv="mkvmerge -q "
for i in $files ; do
  mkv+="$i "
done
mkv+="-o $filename-60fps.mkv"

$mkv

}



echo ------------------------------------------------------
echo Fpska v0.8
echo ------------------------------------------------------

check_files

rm -rf tmp
mkdir tmp

echo Файл для конвертации: $(realpath -e $1)

echo ------------------------------------------------------
echo Извлекаем видео/звук/субтитры
demuxer $(realpath -e $1)

video_stream=$(find tmp -name "video*")

echo ------------------------------------------------------
echo Устанавливаем параметры конвертации в 60 fps
cp ${CWD}/60fps/60fps.template ${CWD}/60fps/60fps.pvy

sed -i "s|\$VIDEO|${CWD}\/$video_stream|g" ${CWD}/60fps/60fps.pvy

ffprobe $(realpath -e $1) &> ${CWD}/tmp/ffprobe.log

python3 ${CWD}/60fps/setfps.py ${CWD}/tmp/ffprobe.log ${CWD}/60fps/60fps.pvy ${CWD}/60fps/s.txt $(ffprobe -i ${CWD}/$video_stream -print_format json -loglevel fatal -show_streams -count_frames -select_streams v | grep nb_read_frames | sed -e 's/.*\"nb_read_frames\": "//' | sed -e 's/\"\,//')

echo ------------------------------------------------------
echo Конвертация в 60 fps
cd ${CWD}/60fps
./60fps.sh
cd ../

rm -f tmp/video-stream*

rm -f tmp/ffprobe.log

echo ------------------------------------------------------
echo Собираем видео/звук/субтитры в контейнер mkv
muxer $(realpath -e $1 | xargs basename)

rm -rf tmp

