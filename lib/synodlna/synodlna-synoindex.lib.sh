#!/opt/bin/bash
#
# author : dbonnefoi@gmail.com 
#

OLD_PWD=$(pwd)

BIN_DIFF=/usr/bin/diff
BIN_FIND=/usr/bin/find
BIN_SORT=/usr/bin/sort
BIN_CAT=/bin/cat
BIN_SYNOINDEX=/usr/syno/bin/synoindex
BIN_PGSQL=/usr/syno/pgsql/bin/psql

DLNA_LOG=

# you can define your drive directory
VOLUME_ROOT=${VOLUME_ROOT:-/volume1}
#
# usage: dlna_initlog "my_output_log.log"
#
function dlna_initlog
{
  DLNA_LOG=$1
  cat /dev/null > $DLNA_LOG
  if [ $? -ne 0 ]; then
     echo "cannot write log" &&  exit 1
  else
    echo "log $DLNA_LOG initialized"
  fi
}

#
# usage : dlna_log "my text"
#
function dlna_log
{
  [ -z "$DLNA_LOG" -o -z "$1" ] && return
  echo "[$(date)|syno-reindex] $1" >> $DLNA_LOG
} 

#
# usage: 
#
function dlna_synoindex_action_detail
{
  local IFS=' '
  local sidx_mode=$1
  
  [ -z "$sidx_mode" ] && return 1
  
  local type_synchro="
-D:Removing obsolete directory
-d:Removing obsolete file
-A:Adding new directory
-a:Adding new file
"
  echo $type_synchro | grep "^$sidx_mode:" | cut -d':' -f2
}  
#
# synchronize your DLNA enabled shares content with Database
# usage: dlna_synoindex $id
#
function dlna_synoindex
{
  local id=$1
  local log_dir=$OLD_PWD/logs
  
  [ -z "$VOLUME_ROOT" ] && echo "VOLUME_ROOT not defined" && return 1
  [ ! -d "$VOLUME_ROOT" ] && echo "VOLUME_ROOT:$VOLUME_ROOT is not a directory" && return 1
   
  # get active content type for defined share ID
  local content_types=$(dlnashares_get_share_active_content_type $id)

  local dlna_short_path=$(dlnashares_get_path $id | cut -d':' -f2)
  
  # create logs directory if needed
  [ ! -d "$log_dir" ] && mkdir "$log_dir"
  local share_name=$(echo $dlna_short_path | sed 's/\///')  
  local output_log=$log_dir/reindex.${share_name}.log
  
  dlna_initlog $output_log
  
  echo $dlna_path
  echo $content_types
  
  [ "$content_types" == "" ] && echo "list of enabled files type empty !" >&2 && return 1
  
  local WORK_DIR=/tmp/mediaindex.$$.${share_name}
  
  local dlna_path=${VOLUME_ROOT}$dlna_short_path
  
  mkdir $WORK_DIR && cd $WORK_DIR
  [ $? -ne 0 ] && echo "cannot create or access $WORK_DIR" >&2 && return 1
  
  dlna_log "** start indexing **"
  
  # Loop through our array.
  for nn in $content_types
  do
     export IFS=$'\n'
     
     echo -e "\n*** analyze content-type:$nn in $dlna_path ***"
     
     # build variables for temporary files 
     local f_db_dir=$nn-db.dir
     local f_db_file=$nn-db.file
     local f_fs_dir=$nn-fs.dir
     local f_fs_file=$nn-fs.file
     local f_dif_dir_ON=$nn-dif-ON.dir
     local f_dif_file_ON=$nn-dif-ON.file
     local f_dif_dir_OFF=$nn-dif-OFF.dir
     local f_dif_file_OFF=$nn-dif-OFF.file
    
     local ignore_folder_list='/@eaDir|/#recycle'

     echo -e "\n## Find all directories ##"
     echo "> searching in Filesystem"
     $BIN_FIND $dlna_path -type d | egrep -v "$ignore_folder_list" > $f_fs_dir
     $BIN_SORT $f_fs_dir -o $f_fs_dir
     wc -l $f_fs_dir
     
     echo "> searching in DB"
     $BIN_PGSQL mediaserver admin -tA -c "select path from directory where path like '$dlna_path%'" > $f_db_dir
     $BIN_SORT $f_db_dir -o $f_db_dir
     wc -l $f_db_dir
     
     echo -e "\n## Find all Files and exclude win files ##"
     
     echo "> searching + sorting in Filesystem"
     $BIN_FIND $dlna_path -type f -o -type l -name '*' | egrep -v '\.(ini|db|sys|zip|ram)$' | egrep -v "$ignore_folder_list" > $f_fs_file
     $BIN_SORT $f_fs_file -o $f_fs_file
     wc -l $f_fs_file
     
     echo "> searching + sorting in DB"
     $BIN_PGSQL mediaserver admin -tA -c "select path from $nn where path like '$dlna_path%'" > $f_db_file
     $BIN_SORT $f_db_file -o $f_db_file
     wc -l $f_db_file
     
     echo -e "\n## searching diffs ##"
     # get added files or dirs
     $BIN_DIFF $f_db_dir  $f_fs_dir  | tail -n+3 | grep "^+" | cut -c2- > $f_dif_dir_ON
     $BIN_DIFF $f_db_file $f_fs_file | tail -n+3 | grep "^+" | cut -c2- > $f_dif_file_ON
     
     # get removed files or dirs
     $BIN_DIFF $f_db_dir  $f_fs_dir  | tail -n+3 | grep "^-" | cut -c2- > $f_dif_dir_OFF
     $BIN_DIFF $f_db_file $f_fs_file | tail -n+3 | grep "^-" | cut -c2- > $f_dif_file_OFF
     
    # main process to synchronize files with Database
    # format :  [synoindex_option]:[file_src]
    type_synchro[1]="-D:${f_dif_dir_OFF}"
    type_synchro[2]="-d:${f_dif_file_OFF}"
    type_synchro[3]="-A:${f_dif_dir_ON}"
    type_synchro[4]="-a:${f_dif_file_ON}"
    
    local idx=
    local last_idx=${#type_synchro[@]}
    
    for idx in $(seq 1 $last_idx)
    do
       line=${type_synchro[$idx]}
       # get synoindex_option
       local sidx_mode=$(echo $line | cut -d':' -f1)
       # get file_src
       local sidx_diff=$(echo $line | cut -d':' -f2)
       # get a description of current operation
       local sidx_desc=$(dlna_synoindex_action_detail $sidx_mode)
       
       echo -e "\n> $sidx_desc"
       # ressources to add/remove
       wc -l $sidx_diff
       local total_files=$(wc -l $sidx_diff | cut -d' ' -f1)
       local f_count=0
       local log_message=
       local msg_length=
       local biggest_message=1
       for i in $($BIN_CAT $sidx_diff)
       do
         let f_count=$f_count+1
         echo "$BIN_SYNOINDEX $sidx_mode \"$i\"" >> synoindex.$nn.log
         $BIN_SYNOINDEX $sidx_mode "$i" 2>&1 >> synoindex.$nn.log
	 log_messages="$sidx_desc: [$f_count/$total_files] $i"
	 msg_length=${#log_messages}
         dlna_log "$log_messages"
	 # empty previous line
	 [ $msg_length -gt $biggest_message ] && biggest_message=$msg_length
	 echo -ne "\r"$(printf "%${biggest_message}s")

	 # display current file
	 echo -ne "\r$log_messages"

       done
    # end of loop for $idx
    done
  # end of loop for $content_types
  done
    
  # back to initial directory
  cd $OLD_PWD
  # removing work directories
  rm -rf $WORK_DIR
    
  dlna_log "** end of indexing **"

}

