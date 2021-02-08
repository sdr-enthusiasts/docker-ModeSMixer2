#!/usr/bin/env bash

# Verbosity (x)
set -x

# If cross-building, we have no way to determine this without looking at the installed binaries using libmagic/file
# Do we have libmagic/file installed

# Make sure `file` (libmagic) is available
if ! which file; then
  echo "ERROR: 'file' (libmagic) not available, cannot detect architecture!"
  exit 1
fi
FILEBINARY=$(which file)
FILEOUTPUT=$("${FILEBINARY}" -L "${FILEBINARY}")

# 32-bit x86
# Example output:
# /usr/bin/file: ELF 32-bit LSB shared object, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-musl-i386.so.1, stripped
# /usr/bin/file: ELF 32-bit LSB shared object, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=d48e1d621e9b833b5d33ede3b4673535df181fe0, stripped  
if echo "${FILEOUTPUT}" | grep "Intel 80386" > /dev/null; then
  ARCH="x86"
fi

# x86-64
# Example output:
# /usr/bin/file: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-musl-x86_64.so.1, stripped
# /usr/bin/file: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=6b0b86f64e36f977d088b3e7046f70a586dd60e7, stripped
if echo "${FILEOUTPUT}" | grep "x86-64" > /dev/null; then
  ARCH="amd64"
fi

# armel
# /usr/bin/file: ELF 32-bit LSB shared object, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.3, for GNU/Linux 3.2.0, BuildID[sha1]=f57b617d0d6cd9d483dcf847b03614809e5cd8a9, stripped
if echo "${FILEOUTPUT}" | grep "ARM" > /dev/null; then

  ARCH="arm"

  # armhf
  # Example outputs:
  # /usr/bin/file: ELF 32-bit LSB shared object, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-musl-armhf.so.1, stripped  # /usr/bin/file: ELF 32-bit LSB shared object, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-armhf.so.3, for GNU/Linux 3.2.0, BuildID[sha1]=921490a07eade98430e10735d69858e714113c56, stripped
  # /usr/bin/file: ELF 32-bit LSB shared object, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-armhf.so.3, for GNU/Linux 3.2.0, BuildID[sha1]=921490a07eade98430e10735d69858e714113c56, stripped
  if echo "${FILEOUTPUT}" | grep "armhf" > /dev/null; then
    ARCH="armhf"
  fi

  # arm64
  # Example output:
  # /usr/bin/file: ELF 64-bit LSB shared object, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-musl-aarch64.so.1, stripped
  # /usr/bin/file: ELF 64-bit LSB shared object, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 3.7.0, BuildID[sha1]=a8d6092fd49d8ec9e367ac9d451b3f55c7ae7a78, stripped
  if echo "${FILEOUTPUT}" | grep "aarch64" > /dev/null; then
    ARCH="aarch64"
  fi

fi

echo "========== Preparing to install ModeSMixer2 for ${ARCH} =========="

if [ "$ARCH" = "amd64" ]
then
    URL_MODESMIXER_DOWNLOAD=$(curl "${URL_XDECO_DOWNLOAD}" | grep -iE "modesmixer2_.*_x86_64_.*\.tgz" | grep -ioE '<a href=".*">' | grep -ioE '"https:\/\/.*"' | cut -d '"' -f 2 | head -1)
    
    # Install old version of OpenSSL, required by this architecture's ModeSMixer2 binary
    {
      echo "deb http://deb.debian.org/debian jessie main contrib non-free"
      echo "deb-src http://deb.debian.org/debian jessie main contrib non-free"
      echo "deb http://security.debian.org/ jessie/updates main contrib non-free"
      echo "deb-src http://security.debian.org/ jessie/updates main contrib non-free"
    } > /etc/apt/sources.list.d/jessie.list
    apt-get update
    apt-get install --no-install-recommends -y libssl1.0.0

elif [ "$ARCH" = "x86" ]
then
    URL_MODESMIXER_DOWNLOAD=$(curl "${URL_XDECO_DOWNLOAD}" | grep -iE "modesmixer2_.*_i386_.*\.tgz" | grep -ioE '<a href=".*">' | grep -ioE '"https:\/\/.*"' | cut -d '"' -f 2 | head -1)
    apt-get update
    apt-get install --no-install-recommends -y libssl1.1

elif [ "$ARCH" = "arm" ]
then
    URL_MODESMIXER_DOWNLOAD=$(curl "${URL_XDECO_DOWNLOAD}" | grep -iE "modesmixer2_rpi1_.*\.tgz" | grep -ioE '<a href=".*">' | grep -ioE '"https:\/\/.*"' | cut -d '"' -f 2 | head -1)
    apt-get update
    apt-get install --no-install-recommends -y libssl1.1

elif [ "$ARCH" = "armhf" ]
then
    URL_MODESMIXER_DOWNLOAD=$(curl "${URL_XDECO_DOWNLOAD}" | grep -iE "modesmixer2_rpi4_.*\.tgz" | grep -ioE '<a href=".*">' | grep -ioE '"https:\/\/.*"' | cut -d '"' -f 2 | head -1)
    apt-get install --no-install-recommends -y libssl1.1

elif [ "$ARCH" = "aarch64" ]
then
    URL_MODESMIXER_DOWNLOAD=$(curl "${URL_XDECO_DOWNLOAD}" | grep -iE "modesmixer2_orange-pi-pc2_.*\.tgz" | grep -ioE '<a href=".*">' | grep -ioE '"https:\/\/.*"' | cut -d '"' -f 2 | head -1)
    apt-get install --no-install-recommends -y libssl1.1
    
else
    echo ""
    echo "ERROR!"
    echo "This build is running on an unsupported architecture ($(uname -m))."
    echo "Please raise an issue on this container's GitHub reporting this."
    echo ""
    exit 1
    
fi

echo "========== Installing ModeSMixer2 for ${ARCH} =========="

# Install prerequisites
apt-get install --no-install-recommends -y \
  libc6 \
  libstdc++6

# Get google drive file ID
if echo "$URL_MODESMIXER_DOWNLOAD" | grep -oP 'open\?id=\K([0-9a-zA-Z\-_])+' > /dev/null 2>&1; then
  MODESMIXER_GDRIVE_FILE_ID=$(echo "$URL_MODESMIXER_DOWNLOAD" | grep -oP 'open\?id=\K([0-9a-zA-Z\-_])+')
elif echo "$URL_MODESMIXER_DOWNLOAD" | grep -oP 'drive.google.com\/file\/d\/\K([0-9a-zA-Z\-_])+' > /dev/null 2>&1; then
  MODESMIXER_GDRIVE_FILE_ID=$(echo "$URL_MODESMIXER_DOWNLOAD" | grep -oP 'drive.google.com\/file\/d\/\K([0-9a-zA-Z\-_])+')
else
  echo "ERROR: Could not determine Google Drive file id"
  exit 1
fi

# Create a direct download link from gdrive
URL_MODESMIXER_DOWNLOAD_DIRECT="https://drive.google.com/uc?export=download&id=${MODESMIXER_GDRIVE_FILE_ID}"

# Download & install modesmixer2
curl --location -o /tmp/modesmixer2.tgz "$URL_MODESMIXER_DOWNLOAD_DIRECT"
file /tmp/modesmixer2.tgz
mkdir -p /opt/modesmixer2
tar xvf /tmp/modesmixer2.tgz -C /opt/modesmixer2
ln -s /opt/modesmixer2/modesmixer2 /usr/local/bin/modesmixer2

# Test
set -e
modesmixer2 --help
