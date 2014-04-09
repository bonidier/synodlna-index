function dlna_inotify_liveupdate
{
  local IT_FIFO=$1

  [ -z "$IT_FIFO" ] && echo "IT_FIFO not defined" && return 1

  if [ ! -e  "$IT_FIFO" ]; then
    echo "FIFO not created:$IT_FIFO"
    return 1
  fi

  local Dir=
  local Events=
  local File=
  local Event_list=
  local sidx_mode=
  local log_message=

  echo "Hum OK, let's catch your activity..."

  # separator between field must be a pipe !
  while IFS='|' read Dir Events File
  do
    sidx_mode=

    case $Events in
      CREATE,ISDIR)                  sidx_mode=-A;;
      CLOSE_WRITE,CLOSE|MOVED_TO)    sidx_mode=-a;;
      DELETE|MOVED_FROM)             sidx_mode=-d;;
      DELETE,ISDIR|MOVED_FROM,ISDIR) sidx_mode=-D;;
      *);; # not catched events
    esac

    # break the loop if event not catched
    [ -z "$sidx_mode" ] && continue

    echo "Dir=$Dir | Events=$Events | File=$File"

    # remove all useless slashs
    local file_to_index=$(readlink -m "${Dir}${File}")
    #debug output about synoindex command 
    echo "$BIN_SYNOINDEX $sidx_mode \"$file_to_index\""
    # execute the synoindex command
    $BIN_SYNOINDEX $sidx_mode "$file_to_index"

    log_message=$(dlna_synoindex_action_detail $sidx_mode)
    echo "log_message:$log_message"
  done < $IT_FIFO

}

