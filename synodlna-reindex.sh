#!/opt/bin/bash
##
# author : Didier BONNEFOI <dbonnefoi@gmail.com>
# inspired by http://forum.synology.com/enu/viewtopic.php?f=37&t=30242
##

DEBUG=0
ARRAY_DEBUG=0

#### LIBS STUFF ####

# to override VOLUME_ROOT variable
[ -f config.sh ] && . ./config.sh

. ./lib/common/arraymap.lib.sh
. ./lib/synodlna/synodlna-shares.lib.sh
. ./lib/synodlna/synodlna-synoindex.lib.sh

[ $? -ne 0 ] && echo "error on includes..." &&  exit 1

#### MAIN ####

count_synoindexd=$(pidof synoindexd | wc -w)
[ $count_synoindexd -gt 1 ] && echo "stop, synoindexd always running..." && exit 1

cmd=$1
short_path=$2

case "$cmd" in
  start)
  
    case "$short_path" in
      all)
    	# we get all existing DLNA shares
         dlna_path=$(dlnashares_get_all_path)
         ;;
      *)
    	[ "$short_path" == "" ] && echo "directory not defined" >&2 && exit 1
    	# we extract the path to analyze
         dlna_path=$(dlnashares_get_all_path | egrep "^[0-9]+:/$short_path$")
      
      ;;
    esac
  
    [ "$dlna_path" == "" ] && echo "bad directory !" >&2 && exit 1

    # get all DLNA directories from database
    dlnashares_extract
    # we start reindex for each share
    for dp in $(echo $dlna_path)
    do
      dlna_id=$(echo $dp | cut -d':' -f1)
      dlna_synoindex $dlna_id
      echo
    done

    ;;
  stop|restart|reload|force-reload)
     echo "Error: argument '$1' not supported" >&2
     exit 3
     ;;
  list)
    echo "here are valid DLNA shares:"
    # get all DLNA directories from database
    dlnashares_extract
    # list all valid shares
    dlnashares_get_all_path | cut -d':' -f2 | sed 's/\// - /g'
    ;;
   *)
     cat <<EOF
Usage:
------
$0 list : list all valid DLNA shares
$0 start a_dlna_share_without_slash
$0 start all
EOF
     exit 3
     ;;
esac


