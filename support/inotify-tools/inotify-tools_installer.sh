#!/bin/sh

# this directory
HERE=$(dirname $0)

IT_ARCHIVE=inotify-tools-3.14.tar.gz
IT_SRCDIR=inotify-tools-3.14
IT_PREFIX=/usr/local/inotify-tools

[ -d "$IT_PREFIX" ] && echo "Inotify-Tools seems already installed to $IT_PREFIX" && exit 1

# binary dependencies management :-)
NEEDS="gcc make wget sudo"
which $NEEDS
[ $? -ne 0 ] && echo "missing something in [$NEEDS]" && exit 1

# download archive if needed
if [ ! -f "$HERE/$IT_ARCHIVE" ]; then 
  /usr/bin/wget http://github.com/downloads/rvoicilas/inotify-tools/$IT_ARCHIVE -O $HERE/$IT_ARCHIVE
fi

# build and install inotify-tools

# the "make install" under sudo to allow install with an alternative user than root
cd $HERE && \
/bin/tar xvzf $IT_ARCHIVE && \
cd $IT_SRCDIR && \
./configure --prefix=$IT_PREFIX && \
make && \
sudo make install

echo -e "\nreturn : $?"

