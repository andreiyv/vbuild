#!/bin/bash

# this script is based on:
# https://github.com/markus-perl/ffmpeg-build-script

#sudo apt-get assume-yes install build-essential
#sudo apt-get update && sudo apt-get --assume-yes install curl libssl-dev zlib1g-dev autoconf libtool autogen shtool pkg-config nasm yasm cmake libsdl2-2.0 libsdl2-dev

VERSION=1.0
CWD=$(pwd)
PACKAGES="$CWD/packages"
WORKSPACE="$CWD/workspace"
CC=clang
LDFLAGS="-L${WORKSPACE}/lib -lm"
CFLAGS="-I${WORKSPACE}/include"
PKG_CONFIG_PATH="${WORKSPACE}/lib/pkgconfig"

# Speed up the process
# Env Var NUMJOBS overrides automatic detection
if [[ -n $NUMJOBS ]]; then
    MJOBS=$NUMJOBS
elif [[ -f /proc/cpuinfo ]]; then
    MJOBS=$(grep -c processor /proc/cpuinfo)
elif [[ "$OSTYPE" == "darwin"* ]]; then
	MJOBS=$(sysctl -n machdep.cpu.thread_count)
else
    MJOBS=4
fi

make_dir () {
	if [ ! -d $1 ]; then
		if ! mkdir $1; then
			printf "\n Failed to create dir %s" "$1";
			exit 1
		fi
	fi
}

remove_dir () {
	if [ -d $1 ]; then
		rm -r "$1"
	fi
}

download () {
	if [ ! -f "$PACKAGES/$2" ]; then

		echo "Downloading $1"
		curl -L --silent -o "$PACKAGES/$2" "$1"

		EXITCODE=$?
		if [ $EXITCODE -ne 0 ]; then
			echo ""
			echo "Failed to download $1. Exitcode $EXITCODE. Retrying in 10 seconds";
			sleep 10
			curl -L --silent -o "$PACKAGES/$2" "$1"
		fi

		EXITCODE=$?
		if [ $EXITCODE -ne 0 ]; then
			echo ""
			echo "Failed to download $1. Exitcode $EXITCODE";
			exit 1
		fi

		echo "... Done"


case "$1" in
    *.tar.gz)  
		if ! tar -xvf "$PACKAGES/$2" -C "$PACKAGES" 2>/dev/null >/dev/null; then
			echo "Failed to extract $2";
			exit 1
		fi
	;;
	
    *.tar.bz2)  
		if ! tar -jxf "$PACKAGES/$2" -C "$PACKAGES" 2>/dev/null >/dev/null; then
			echo "Failed to extract $2";
			exit 1
		fi
	;;
	
    *.tgz)  
		if ! tar -xvf "$PACKAGES/$2" -C "$PACKAGES" 2>/dev/null >/dev/null; then
			echo "Failed to extract $2";
			exit 1
		fi
	;;	
    *.zip)     
		if ! unzip "$PACKAGES/$2" -d "$PACKAGES" 2>/dev/null >/dev/null; then
			echo "Failed to unzip $2";
			exit 1
		fi
	;;
    *)         
	;;
esac




	fi
}

execute () {
	echo "$ $*"

	OUTPUT=$($@ 2>&1)

	if [ $? -ne 0 ]; then
        echo "$OUTPUT"
        echo ""
        echo "Failed to Execute $*" >&2
        exit 1
    fi
}

build () {
	echo ""
	echo "building $1"
	echo "======================="

	if [ -f "$PACKAGES/$1.done" ]; then
		echo "$1 already built. Remove $PACKAGES/$1.done lockfile to rebuild it."
		return 1
	fi

	return 0
}

command_exists() {
    if ! [[ -x $(command -v "$1") ]]; then
        return 1
    fi

    return 0
}


build_done () {
	touch "$PACKAGES/$1.done"
}

echo "ffmpeg-build-script v$VERSION"
echo "========================="
echo ""

#case "$1" in
#"--cleanup")
#	remove_dir $PACKAGES
#	remove_dir $WORKSPACE
#	echo "Cleanup done."
#	echo ""
#	exit 0
#    ;;
#"--build")

#    ;;
#*)
#    echo "Usage: $0"
#    echo "   --build: start building process"
#    echo "   --cleanup: remove all working dirs"
#    echo "   --help: show this help"
#    echo ""
#    exit 0
#    ;;
#esac

echo "Using $MJOBS make jobs simultaneously."

make_dir $PACKAGES
make_dir $WORKSPACE

export PATH=${WORKSPACE}/bin:$PATH
export PKG_CONFIG_PATH=${WORKSPACE}/lib/pkgconfig:$PKG_CONFIG_PATH
export PKG_CONFIG_PATH=${WORKSPACE}/lib64/pkgconfig:$PKG_CONFIG_PATH

#echo "export PATH="$PWD"/workspace/bin:\$PATH" > vset.sh
#echo "export LD_LIBRARY_PATH="$PWD"/workspace/lib:\$LD_LIBRARY_PATH" >> vset.sh
#echo "export PYTHONPATH="$PWD"/workspace/lib:\$PYTHONPATH" >> vset.sh
#echo "export PYTHONPATH="$PWD"/workspace/lib/python3.6/site-packages:\$PYTHONPATH" >> vset.sh

if ! command_exists "make"; then
    echo "make not installed.";
    exit 1
fi

if ! command_exists "g++"; then
    echo "g++ not installed.";
    exit 1
fi

if ! command_exists "curl"; then
    echo "curl not installed.";
    exit 1
fi


if build "lame"; then
	download "http://kent.dl.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz" "lame-3.100.tar.gz"
	cd $PACKAGES/lame-3.100 || exit
	execute ./configure --prefix=${WORKSPACE} --enable-shared
	execute make -j $MJOBS
	execute make install
	build_done "lame"
fi

export LD_LIBRARY_PATH=${WORKSPACE}/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${WORKSPACE}/lib64:$LD_LIBRARY_PATH



if build "cmake"; then
	download "https://github.com/Kitware/CMake/archive/release.zip" "CMake-release.zip"
	cd $PACKAGES/CMake-release
	execute ./configure --prefix=${WORKSPACE}
	execute gmake
	execute gmake install
	build_done "cmake"
fi


if build "av1"; then
	cd ${PACKAGES}
	pwd
	git clone https://aomedia.googlesource.com/aom
	${WORKSPACE}/bin/cmake ${PACKAGES}/aom -DCMAKE_INSTALL_PREFIX=${WORKSPACE} -DBUILD_SHARED_LIBS=1
	make
	make install
	build_done "av1"
fi


if build "python"; then
	download "https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tgz" "Python-3.7.4.tgz"
	cd $PACKAGES/Python-3.7.4
	execute ./configure --prefix=${WORKSPACE}  --enable-shared
	execute make
	execute make install
	cd ${WORKSPACE}/bin
        execute ./pip3 install Cython
        build_done "python"
fi

if build "zimg"; then
        download "https://github.com/sekrit-twc/zimg/archive/master.zip" "zimg.zip"
        cd $PACKAGES/zimg-master
        execute ./autogen.sh
        execute ./configure --prefix=${WORKSPACE} --enable-shared
        execute make -j $MJOBS
        execute make install
        build_done "zimg"
fi

#if build "yasm"; then
#	download "http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz" "yasm-1.3.0.tar.gz"
#	cd $PACKAGES/yasm-1.3.0 || exit
#	execute ./configure --prefix=${WORKSPACE}
#	execute make -j $MJOBS
#	execute make install
#	build_done "yasm"
#fi

if build "nasm"; then
	download "http://www.nasm.us/pub/nasm/releasebuilds/2.14/nasm-2.14.tar.gz" "nasm.tar.gz"
	cd $PACKAGES/nasm-2.14 || exit
	execute ./configure --prefix=${WORKSPACE} --enable-shared
	execute make -j $MJOBS
	execute make install
	build_done "nasm"
fi

if build "opencore"; then
	download "http://downloads.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-0.1.5.tar.gz" "opencore-amr-0.1.5.tar.gz"
	cd $PACKAGES/opencore-amr-0.1.5 || exit
	execute ./configure --prefix=${WORKSPACE} --enable-shared
	execute make -j $MJOBS
	execute make install
	build_done "opencore"
fi

if build "libvpx"; then
    download "https://github.com/webmproject/libvpx/archive/master.zip" "libvpx-master.zip"
    cd $PACKAGES/libvpx-master || exit

    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Applying Darwin patch"
        sed "s/,--version-script//g" build/make/Makefile > build/make/Makefile.patched
        sed "s/-Wl,--no-undefined -Wl,-soname/-Wl,-undefined,error -Wl,-install_name/g" build/make/Makefile.patched > build/make/Makefile
    fi

	execute ./configure --prefix=${WORKSPACE} --disable-unit-tests --enable-shared
	execute make -j $MJOBS
	execute make install
	build_done "libvpx"
fi



if build "xvidcore"; then
	download "https://downloads.xvid.com/downloads/xvidcore-1.3.5.tar.gz" "xvidcore-1.3.5.tar.gz"
	cd $PACKAGES/xvidcore  || exit
	cd build/generic  || exit
	execute ./configure --prefix=${WORKSPACE} --enable-shared
	execute make -j $MJOBS
	execute make install

	if [[ -f ${WORKSPACE}/lib/libxvidcore.4.dylib ]]; then
	    execute rm "${WORKSPACE}/lib/libxvidcore.4.dylib"
	fi

	build_done "xvidcore"
fi

if build "x264"; then
	download "http://ftp.videolan.org/pub/x264/snapshots/last_stable_x264.tar.bz2" "last_stable_x264.tar.bz2"
	cd $PACKAGES/x264-snapshot-* || exit

	if [[ "$OSTYPE" == "linux-gnu" ]]; then
		execute ./configure --prefix=${WORKSPACE} --enable-shared --enable-pic CXXFLAGS="-fPIC"
    else
        execute ./configure --prefix=${WORKSPACE} --enable-shared --enable-pic
    fi

    execute make -j $MJOBS
	execute make install
	execute make install-lib-static
	build_done "x264"
fi

if build "libogg"; then
	download "http://downloads.xiph.org/releases/ogg/libogg-1.3.4.tar.gz" "libogg-1.3.4.tar.gz"
	cd $PACKAGES/libogg-1.3.4 || exit
	execute ./configure --prefix=${WORKSPACE} --enable-shared
	execute make -j $MJOBS
	execute make install
	build_done "libogg"
fi

if build "libvorbis"; then
	download "http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.6.tar.gz" "libvorbis-1.3.6.tar.gz"
	cd $PACKAGES/libvorbis-1.3.6 || exit
	execute ./configure --prefix=${WORKSPACE} --with-ogg-libraries=${WORKSPACE}/lib --with-ogg-includes=${WORKSPACE}/include/ --enable-shared --disable-oggtest
	execute make -j $MJOBS
	execute make install
	build_done "libvorbis"
fi

if build "libtheora"; then
	download "http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.gz" "libtheora-1.1.1.tar.bz"
	cd $PACKAGES/libtheora-1.1.1 || exit
	sed "s/-fforce-addr//g" configure > configure.patched
	chmod +x configure.patched
	mv configure.patched configure
	execute ./configure --prefix=${WORKSPACE} --with-ogg-libraries=${WORKSPACE}/lib --with-ogg-includes=${WORKSPACE}/include/ --with-vorbis-libraries=${WORKSPACE}/lib --with-vorbis-includes=${WORKSPACE}/include/ --enable-shared --disable-oggtest --disable-vorbistest --disable-examples --disable-asm
	execute make -j $MJOBS
	execute make install
	build_done "libtheora"
fi

if build "pkg-config"; then
	download "http://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz" "pkg-config-0.29.2.tar.gz"
	cd $PACKAGES/pkg-config-0.29.2 || exit
	execute ./configure --silent --prefix=${WORKSPACE} --with-pc-path=${WORKSPACE}/lib/pkgconfig --with-internal-glib
	execute make -j $MJOBS
	execute make install
	build_done "pkg-config"
fi

#if build "cmake"; then
#	download "https://cmake.org/files/v3.11/cmake-3.11.3.tar.gz" "cmake-3.11.3.tar.gz"
#	cd $PACKAGES/cmake-3.11.3  || exit
#	rm Modules/FindJava.cmake
#	perl -p -i -e "s/get_filename_component.JNIPATH/#get_filename_component(JNIPATH/g" Tests/CMakeLists.txt
#	perl -p -i -e "s/get_filename_component.JNIPATH/#get_filename_component(JNIPATH/g" Tests/CMakeLists.txt
#	execute ./configure --prefix=${WORKSPACE}
#	execute make -j $MJOBS
#	execute make install
#	build_done "cmake"
#fi



if build "x265"; then
	download "https://bitbucket.org/multicoreware/x265/downloads/x265_3.0.tar.gz" "x265-3.0.tar.gz"
	cd $PACKAGES/x265_3.0 || exit
	cd source || exit
	execute cmake -DCMAKE_INSTALL_PREFIX:PATH=${WORKSPACE} -DENABLE_SHARED:bool=on .
	execute make -j $MJOBS
	execute make install
	sed "s/-lx265/-lx265 -lstdc++/g" "$WORKSPACE/lib/pkgconfig/x265.pc" > "$WORKSPACE/lib/pkgconfig/x265.pc.tmp"
	mv "$WORKSPACE/lib/pkgconfig/x265.pc.tmp" "$WORKSPACE/lib/pkgconfig/x265.pc"
	build_done "x265"
fi

#if build "fdk_aac"; then
#	download "https://netcologne.dl.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-2.0.0.tar.gz" "fdk-aac-2.0.0.tar.gz"
#	cd $PACKAGES/fdk-aac-2.0.0 || exit
#	execute ./configure --prefix=${WORKSPACE} --enable-shared
#	execute make -j $MJOBS
#	execute make install
#	build_done "fdk_aac"
#fi


#if build "SDL"; then
#        download "https://www.libsdl.org/release/SDL2-2.0.9.tar.gz" "SDL2-2.0.9.tar.gz"
#        cd $PACKAGES/SDL2-2.0.9 || exit
#        execute ./configure --prefix=${WORKSPACE} --enable-shared
#        execute make -j $MJOBS
#        execute make install
#        build_done "SDL"
#fi


if build "vapoursynth"; then
	download "https://github.com/vapoursynth/vapoursynth/archive/R46.zip" "vapoursynth.zip"
	cd $PACKAGES/vapoursynth-R46
	execute ./autogen.sh
	execute ./configure --prefix=${WORKSPACE} --enable-shared --with-cython=${WORKSPACE}/bin/cython
	execute make
	execute make install
        build_done "vapoursynth"
fi

if build "ihistogram"; then
        download "https://github.com/dubhater/vapoursynth-histogram/archive/master.zip" "histogram.zip"
        cd $PACKAGES/vapoursynth-histogram-master
        execute chmod +x ./autogen.sh
        execute ./autogen.sh
        execute ./configure --prefix=${WORKSPACE} --enable-shared
        execute make -j $MJOBS
        execute make install
	execute mv ${WORKSPACE}/lib/libhistogram.* ${WORKSPACE}/lib/vapoursynth
        build_done "histogram"
fi

build "ffmpeg"
#download "http://ffmpeg.org/releases/ffmpeg-3.4.5.tar.gz" "ffmpeg-3.4.5.tar.gz"
download "http://ffmpeg.org/releases/ffmpeg-4.2.1.tar.gz" "ffmpeg-4.2.1.tar.gz"
#cd $PACKAGES/ffmpeg-3.4.5 || exit
cd $PACKAGES/ffmpeg-4.2.1 || exit

./configure \
    --pkgconfigdir="$WORKSPACE/lib/pkgconfig" \
    --prefix=${WORKSPACE} \
    --extra-cflags="-I$WORKSPACE/include" \
    --extra-ldflags="-L$WORKSPACE/lib" \
    --extra-libs="-lpthread -lm" \
	--disable-debug \
	--enable-shared \
	--enable-ffplay \
	--disable-doc \
	--enable-gpl \
	--enable-version3 \
	--enable-nonfree \
	--enable-pthreads \
	--enable-libvpx \
	--enable-libmp3lame \
	--enable-libtheora \
	--enable-libvorbis \
	--enable-libx264 \
	--enable-libx265 \
	--enable-runtime-cpudetect \
	--enable-avfilter \
	--enable-libopencore_amrwb \
	--enable-libopencore_amrnb \
	--enable-filters \
	--enable-libaom \
	--enable-sdl2
	# enable all filters
	# enable AAC de/encoding via libfdk-aac [no]
	# enable detecting cpu capabilities at runtime (smaller binary)
	# enable HEVC encoding via x265 [no]
	# enable H.264 encoding via x264 [no]
	# enable Vorbis en/decoding via libvorbis, native implementation exists [no]
	# enable Theora encoding via libtheora [no]
	# enable MP3 encoding via libmp3lame [no]
	# enable VP8 and VP9 de/encoding via libvpx [no]
	# enable pthreads [autodetect]
	# allow use of nonfree code, the resulting libs and binaries will be unredistributable [no]
	# upgrade (L)GPL to version 3 [no]
	# allow use of GPL code, the resulting libs and binaries will be under GPL [no]
	# do not build documentation
	# disable ffserver build
	# disable ffplay build
	# build static libraries [no]
	# disable debugging symbols
	# disable build shared libraries [no]
execute make -j $MJOBS

execute make install

INSTALL_FOLDER="/usr/bin"
if [[ "$OSTYPE" == "darwin"* ]]; then
INSTALL_FOLDER="/usr/local/bin"
fi

echo ""
echo "Building done. The binary can be found here: $WORKSPACE/bin/ffmpeg"
echo ""

if build "ffms2"; then
        download "https://github.com/FFMS/ffms2/archive/2.23.tar.gz" "2.23.tar.gz"
        cd $PACKAGES/ffms2-2.23 || exit
        execute ./autogen.sh
#	execute autoreconf -i
#        execute ./autogen.sh
        execute ./configure --prefix=${WORKSPACE} --disable-static --enable-shared
        execute make -j $MJOBS
#        execute make install
	execute cp $PACKAGES/ffms2-2.23/src/core/.libs/libffms2.so.4.0.0 ${WORKSPACE}/lib/vapoursynth/ffms2.so
        build_done "ffms2"
fi

if build "fftw"; then
        download "http://www.fftw.org/fftw-3.3.8.tar.gz" "fftw-3.3.8.tar.gz"
        cd $PACKAGES/fftw-3.3.8 || exit
        execute ./configure --prefix=${WORKSPACE} --enable-shared --enable-threads --enable-float
        execute make -j $MJOBS
        execute make install
        build_done "fftw"
fi

if build "fft3dfilter"; then
        download "https://github.com/andreiyv/fft3dfilter/archive/master.zip" "fft3dfilter.zip"
        cd $PACKAGES/fft3dfilter-master/src || exit
#        execute g++ -shared -o fft3dfilter.so fft3dfilter_c.cpp FFT3DFilter.cpp Plugin.cpp -I../../../workspace/include/vapoursynth -I../../../workspace/include -fPIC 
	execute g++ -shared -o fft3dfilter.so fft3dfilter_c.cpp FFT3DFilter.cpp Plugin.cpp -I../../../workspace/include/vapoursynth -I../../../workspace/include -fPIC -Wno-reorder -DHAVE_FFTW3_MAKE_PLANNER_THREAD_SAFE -L../../../workspace/lib -lfftw3f_threads -lfftw3f -std=c++11
        execute cp $PACKAGES/fft3dfilter-master/src/fft3dfilter.so ${WORKSPACE}/lib/vapoursynth/fft3dfilter.so
        build_done "fft3dfilter"
fi

sed -i "s|pwd_dir|$PWD|g" set-env.sh

#if [[ $AUTOINSTALL == "yes" ]]; then
#	if command_exists "sudo"; then
#		sudo cp "$WORKSPACE/bin/ffmpeg" "$INSTALL_FOLDER/ffmpeg"
#		sudo cp "$WORKSPACE/bin/ffprobe" "$INSTALL_FOLDER/ffprobe"
#		echo "Done. ffmpeg is now installed to your system"
#	fi
#elif [[ ! $SKIPINSTALL == "yes" ]]; then
#	if command_exists "sudo"; then

#		read -r -p "Install the binary to your $INSTALL_FOLDER folder? [Y/n] " response

#		case $response in
#    		[yY][eE][sS]|[yY])
#        		sudo cp "$WORKSPACE/bin/ffmpeg" "$INSTALL_FOLDER/ffmpeg"
#        		sudo cp "$WORKSPACE/bin/ffprobe" "$INSTALL_FOLDER/ffprobe"
#        		echo "Done. ffmpeg is now installed to your system"
#        		;;
#		esac
#	fi
#fi

exit 0
