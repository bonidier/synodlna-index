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

# build and check inotify-tools
cd $HERE && \
/bin/tar xvzf $IT_ARCHIVE && \
cd $IT_SRCDIR && \
./configure --prefix=$IT_PREFIX && \
make

make_return=$?

make_check_return=
can_install=

if [ $make_return -eq 0 ]; then
  # build successful, now testing

  debug_makecheck=debug_makecheck.log
  echo -e "\nbuild OK, running tests..."
  MALLOC_TRACE=/tmp/inotify-tools-issue-34.log make check &> ${debug_makecheck}
  make_check_return=$?

  if [ $make_check_return -eq 0 ]; then
    # make check return no error
    can_install=0
  else
    # tests fail, checking for an acceptable error
    grep -F "Test 'watch_limit' failed: Verification failed" ${debug_makecheck}
    acceptable_error=$?

    if [ $acceptable_error -eq 0 ]; then
      read -p "this failed test is acceptable..., press ENTER to continue"
      can_install=0
    else
      echo "Something wrong during tests, passing installation... see file '${debug_makecheck}'"
      echo "Here is the MALLOC_TRACE file : $MALLOC_TRACE"
      can_install=1
    fi
  fi
  # the "make install" under sudo to allow install with an alternative user than root
  [ $can_install -eq 0 ] && sudo make install && echo -e "\ninotify-tools successfuly installed !"
fi

echo -e "\nSome debug informations about build (0 = OK) :"
echo -e "'make' return : $make_return"
echo -e "'make check' return : $make_check_return"
echo -e "has acceptable_error (watch_limit test) : $acceptable_error"
echo -e "'make install' return : $can_install"

