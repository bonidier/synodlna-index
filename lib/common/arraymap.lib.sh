#!/usr/bin/bash
#
# @author Didier BONNEFOI <dbonnefoi@gmail.com>
# functions to simulate associative array, useful on older bash release
# (tested under Bash 3.x)
#

#
# if variable ARRAY_DEBUG defined to 1, 
# display verbose output for array_add/array_get functions
#
# 
# requirement : 
# define your keys and an uniq numeric value
# variableX=123
# variableY=456
# variableZ=789
# 
# usage: array_mapset variableX variableY variableZ
#
function array_mapset
{
  [ $# -eq 0 ] && echo "array_mapset: missing parameters" >&2 && return 1
  local v
  # ensure variables are defined and numeric
  for v in $@
  do
    ref=$v
    if [ $(echo ${!ref} | egrep '^[0-9]+$' | wc -l) -ne 1 ]; then
      echo "$v not defined or not numeric, stop !" && return 1
    fi
  done
  
  # fill _array_idx with all defined keys  
  _array_idx=($@)
  return 0
}

# return all defined indexes
function array_mapget
{
  echo ${_array_idx[*]}
}

#
# add value for key in array
# usage: array_add $array_name $idx $value
#
function array_add
{
    [ $# -ne 3 ] && echo "array_add: missing parameters" && return

    local key=$2

    # if the key isn't numeric, we map with the variable
    if [ $(echo $key | egrep '^[0-9]+$' | wc -l) -ne 1 ]; then
      keyid=${!key}
    else
      keyid=$key
    fi
    eval $1[$keyid]=\"$3\"
    
   [ "$ARRAY_DEBUG" == "1" ] && echo "debug: $1[$key]=$3" >&2
}

#
# get value for defined key
# key may be numeric ou alphanumeric
# usage: array_get $array_name $index
#
function array_get 
{
  [ $# -ne 2 ] && echo "array_get: missing parameters" && return
  
  local key=$2
    
  # if the key isn't numeric, we map with the variable
  if [ $(echo $key | egrep '^[0-9]+$' | wc -l) -ne 1 ]; then
    keyid=${!key}
  else
    keyid=$key
  fi
  local ref=$1[$keyid]
  echo ${!ref}
  
  [ "$ARRAY_DEBUG" == "1" ] && echo "debug:keyid=$keyid $1[$key]=${!ref}" >&2
}

# array_dump [array_name]
function array_dump
{
  echo "== dumping array $1 =="
  for idx in ${_array_idx[*]} 
  do                         
    echo -n "$idx => "
    array_get $1 ${idx}
  done
  echo
}

