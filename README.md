# vbuild-centos
Vapoursynth build script for CentOS (works fine for 7.6)

You will receive Vapoursynth + filters + ffmpeg/ffplay/ffprobe when installation completed.

# Required packages
```bash
sudo apt-get update
sudo apt-get --assume-yes install build-essential
sudo apt-get --assume-yes install curl libssl-dev zlib1g-dev autoconf libtool autogen shtool pkg-config nasm yasm cmake libsdl2-2.0 libsdl2-dev
```
# Installation
```bash
git clone https://github.com/andreiyv/vbuild.git
cd vbuild
./vbuild-ubuntu.sh
```
# Set environment 
```bash
. ./set-env.sh
```
# Testing
```bash
cd test
./vtest.sh # basic test (just magenta rectangle)
./histogram.sh # lightness and color distribution
./decompose.sh # split image on to 3 layers (L + U + V)
./denoise.sh # using of noise removal filter (FFTW3d) with extra settings (soft effect)
./60fps.sh # convert from 25->50fps or 30->60fps using SVP Team libraries 
```
