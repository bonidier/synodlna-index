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

  local BIN_READLINK=/opt/bin/readlink

  if [ ! -x "$BIN_READLINK" ]; then
    echo "$BIN_READLINK not present"
    return 1
  fi
  
  echo "Hum OK, let's catch your activity..."
  echo "!! you should wait the inotifywait's line 'Watches established'"

  # will contain file path if 'modify' event catched
  local modified_file=

  # separator between field must be a pipe !
  while IFS='|' read Dir Events File
  do
    sidx_mode=

    case $Events in

      # directory stuff
      CREATE,ISDIR|MOVED_TO,ISDIR)
        sidx_mode=-A;;
      DELETE,ISDIR|MOVED_FROM,ISDIR)
        sidx_mode=-D;;

      # file stuff
      CLOSE_WRITE,CLOSE)
        # /!\ here is a bypass because of synomediaparserd  /!\
        # each analyzed file opened synomediaparserd with write flag (O_RDWR), without modification
        # so when closing, each file is catched by inotifywait and re-added in the pipe and overload your NAS !

        # we forward to synoindex only if file has been modified
        if [ "$modified_file" == "$Dir$File" ]; then 
          sidx_mode=-a
        else
          [ "$DEBUG" == "1" ] && echo "[debug] silently ignore $Dir$File, not modified !"
        fi
        ;;
      MODIFY)
        # file has been modified, we store his path
        modified_file=$Dir$File
        ;;
      MOVED_TO)
        sidx_mode=-a;;
      DELETE|MOVED_FROM)
        sidx_mode=-d;;
      DELETE,ISDIR|MOVED_FROM,ISDIR)
        sidx_mode=-D;;

      *)
        # not catched events
        echo "IGNORING Events : $Events";;
    esac


    # break the loop if event not catched
    [ -z "$sidx_mode" ] && continue

    # remove all useless slashes
    local file_to_index=$($BIN_READLINK -m "${Dir}${File}")

    #debug output about file to pass to synoindex
    if [ "$DEBUG" == "1" ]; then
      echo "[debug] Dir=$Dir | Events=$Events | File=$File"
    fi

    # execute the synoindex command
    $BIN_SYNOINDEX $sidx_mode "$file_to_index"

    # reset flag about modified file path
    modified_file=""

    log_message=$(dlna_synoindex_action_detail $sidx_mode)
    echo "$log_message: $file_to_index"

  done < $IT_FIFO

}

