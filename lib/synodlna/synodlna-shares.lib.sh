#!/opt/bin/bash
#              
# author : dbonnefoi@gmail.com
#  

# require arraymap.lib.sh !

#
# return total shares count in variable $nbshare
# more verbose information if DEBUG=1
#
function dlnashares_extract
{
  #mapping some keys to id
  DLNA_default=0
  DLNA_path=1
  DLNA_name=2
  DLNA_music=3
  DLNA_photo=4
  DLNA_video=5

  array_mapset DLNA_default DLNA_path DLNA_name DLNA_music DLNA_photo DLNA_video || exit 1
  
  #simulate default DLNA shares : 
  array_add share1 DLNA_path "/photo"
  array_add share1 DLNA_default true
  array_add share1 DLNA_photo true
  array_add share2 DLNA_path "/music"
  array_add share2 DLNA_default true
  array_add share2 DLNA_music true
  array_add share3 DLNA_path "/video"
  array_add share3 DLNA_video true
  array_add share3 DLNA_default true
  
  # we start from 3, because of default shares count
  nbshares=3  
  
  # synology file with all shared folder informations :-)
  local IDX_FOLDER_DLNA=/usr/syno/etc/index_folder.conf
  # temporary for filtered output of original file
  local FILTERED_DLNA_SHARES=index_folder_for_bash.conf
    
  # we remove some lines & characters for an easiest extraction
  cat $IDX_FOLDER_DLNA | egrep ':|\{' |  tr -d ',:"'  > $FILTERED_DLNA_SHARES

  [ "$DEBUG" == "1" ] && echo "** parsing DLNA folders from $IDX_FOLDER_DLNA to arrays :-) **"
  while read key value
  do
    if [ "$key" == "{" ]; then
      let nbshares=nbshares+1
      [ "$DEBUG" == "1" ] && echo -e "[share $nbshares]\n"
      continue
    fi
  
    case $key in
      music|photo|video|path|name|default)
        [ "$DEBUG" == "1" ] && echo -e "\t$key => $value"
        # we generate array's key for the line
        keymap=DLNA_$key
        array_add share$nbshares $keymap $value
        ;;
      *)
        echo -e "\t[not_implemented] $key => $value"
        ;;
    esac
  done < $FILTERED_DLNA_SHARES
  
  rm -f $FILTERED_DLNA_SHARES
  
}

#
# return list of all DLNA shares
# id1:name1
# id2:name2
#
function dlnashares_get_all_path
{
  for i in $(seq 1 $nbshares)
  do
    dlnashares_get_path $i
  done
}

#
# return physical DLNA shares list
# usage : dlnashares_get_path id
#
# return :
# id:name1
#
function dlnashares_get_path
{
  [ $# -ne 1 ] && echo "missing parameter" >&2 && exit 1
  local id=$1
  [ $(echo $id | egrep '^[0-9]+$' | wc -l) -ne 1 ] && echo "dlnashares_get_path:NaN" >&2 && exit 1
  echo -n "$id:"
  array_get share$id DLNA_path
}

#
# return enabled content types (music|photo|video) for a defined share
# dlnashares_get_share_active_content_type share_id
#
function dlnashares_get_share_active_content_type
{
  [ $# -ne 1 ] && echo "missing parameter" >&2 && exit 1
  local id=$1
  [ $(echo $id | egrep '^[0-9]+$' | wc -l) -ne 1 ] && echo "dlnashares_get_share_active_content_type:NaN" >&2 && exit 1
  
  {  
  echo "music="$(array_get share$id DLNA_music)
  echo "photo="$(array_get share$id DLNA_photo)
  echo "video="$(array_get share$id DLNA_video)
  } | grep '=true$' | cut -d'=' -f1
}

