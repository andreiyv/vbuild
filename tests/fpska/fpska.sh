CWD=$(pwd)

rm -rf tmp
mkdir tmp

cd demux
./demux.sh ${CWD}/$1

cd ../
video_stream=$(find tmp -name "video*")
echo ${CWD}/$video_stream

cp ${CWD}/60fps/60fps.template ${CWD}/60fps/60fps.pvy

sed -i "s|\$VIDEO|${CWD}\/$video_stream|g" ${CWD}/60fps/60fps.pvy

cd ${CWD}/60fps
pwd
./60fps.sh

cd ${CWD}/tmp
rm -f video-stream*

