# vbuild v0.2.1
Vapoursynth build script for Ubuntu 18.04 and CentOS 7.6

You will receive Vapoursynth + filters + ffmpeg/ffplay/ffprobe when installation completed.

Next standalone applications will be available:


# Required packages
Ubuntu
```bash
sudo apt-get update
sudo apt-get assume-yes install build-essential
sudo apt-get update && sudo apt-get --assume-yes install curl libssl-dev zlib1g-dev autoconf libtool autogen shtool pkg-config nasm yasm cmake libsdl2-2.0 libsdl2-dev libffi-dev
```
CentOS
```bash
yum install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libffi-devel nasm SDL2 SDL-dev libxext-dev
```

# Installation
```bash
git clone https://github.com/andreiyv/vbuild.git
cd vbuild
./vbuild.sh
```
# Set environment 
```bash
. ./set-env.sh
```
# Testing
```bash
cd tests
./vtest # basic test (just magenta rectangle)
./histogram # lightness and color distribution
./decompose # split image on to 3 layers (L + U + V)
./denoise # using of noise removal filter (FFTW3d) with extra settings (soft effect)
./60fps # convert from 25->50fps or 30->60fps using SVP Team libraries
./av1 # convert using av1 codec
```
