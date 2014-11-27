#!/bin/sh

# this directory
HERE=$(dirname $0)

IT_ARCHIVE=inotify-tools-3.14.tar.gz
IT_SRCDIR=inotify-tools-3.14
IT_PREFIX=/usr/local/inotify-tools

[ -d "$IT_PREFIX" ] && echo "Inotify-Tools seems already installed to $IT_PREFIX" && exit 0

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
make
ret_make=$?

if [ $ret_make -eq 0 ]; then
  debug_makecheck=debug_makecheck.log
  echo -e "\nrunning tests..."
  MALLOC_TRACE=/tmp/inotify-tools-issue-34.log make check &> ${debug_makecheck}
  test_return=$?
  if [ $test_return -ne 0 ]; then
    grep -F "Test 'watch_limit' failed: Verification failed" ${debug_makecheck}
    [ $? -eq 0 ] && read -p "this failed test is acceptable..., press ENTER to continue"
    sudo make install
    [ $? -eq 0 ] && echo -e "\ninotify-tools successfuly installed !"
  else
    echo "Something wrong during tests, passing installation... see ${debug_makecheck}"
    echo "Here is the MALLOC_TRACE file : $MALLOC_TRACE"
  fi
fi

echo -e "\nreturn : $ret_make"

