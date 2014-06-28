#!/opt/bin/bash

HERE=$(dirname $0)

[ -f $HERE/config.sh ] && . $HERE/config.sh

. $HERE/lib/common/arraymap.lib.sh
. $HERE/lib/synodlna/synodlna-shares.lib.sh
. $HERE/lib/synodlna/synodlna-synoindex.lib.sh
. $HERE/lib/synodlna/synodlna-synoindex-inotify.lib.sh

function on_exit
{
  echo "catch end of script, killing PID[$IT_PID] and dropping inotifywait FIFO"
  [ ! -z "$IT_PID" ] && /bin/kill $IT_PID
  /bin/rm -v $IT_FIFO
  exit
}

trap on_exit SIGINT SIGTERM

IT_FIFO=/tmp/synodlna-reindex-inotify.fifo
IT_BIN=/usr/local/inotify-tools/bin
IT_ONLY_EVENTS="
-e close_write
-e moved_to
-e moved_from
-e move
-e create
-e delete
"
IT_EXCLUDE="(@eaDir|#recycle)"

# get all DLNA directories from database               
dlnashares_extract
DLNA_SHARES=$(dlnashares_get_all_path |  cut -d':' -f2)

IT_WATCHDIR=
for s in $DLNA_SHARES
do
  echo "set share '$s' to be watched by inotify"
  IT_WATCHDIR="$IT_WATCHDIR $VOLUME_ROOT/$s"
done


echo "launching inotifywait...:"

[ ! -e  "$IT_FIFO" ] && /opt/bin/mkfifo "$IT_FIFO"
$IT_BIN/inotifywait -rm ${IT_ONLY_EVENTS} ${IT_WATCHDIR} --exclude=${IT_EXCLUDE} --format "%w|%e|%f"  -o ${IT_FIFO} &
IT_PID=$!
echo "PID INOTIFY=${IT_PID}"
echo "DEBUG : $DEBUG"

dlna_inotify_liveupdate ${IT_FIFO}
 
