# Introduction

This script synchronize each of your DLNA shared folders with Synology mediaserver Database, using synoindex utility

When you send your files over SSH, DSM is unable to refresh each of them

you can start (re)index one or all your shares (default shares + auto-detected user defined shares)

# requirement

 - SSH access to your Synology NAS
 - IPKG bootstrap (http://forum.synology.com/wiki/index.php/Overview_on_modifying_the_Synology_Server%2C_bootstrap%2C_ipkg_etc#What_do_I_need_to_do)

 - install bash 3.x
 - install git (if you want to get this script from github repository)
 
 ```
 ipkg install bash git
 ```

# installation

under "admin" user :

```
git clone https://github.com/bonidier/synodlna-index.git synodlna-index
```
 
# Volume configuration

you can override your RAID volume if different of /volume1 :

```
cp config.sh.dist config.sh
vi config.sh
VOLUME_ROOT=...
```

# usage

**embedded help**
```
./synodlna-reindex.sh
```

**show all your shares**
this option will list default + user defined share (detected :-) )
```
./synodlna-reindex.sh list
```
**reindex all shares**
```
./synodlna-reindex.sh start all
```
**reindex one share**
```
./synodlna-reindex.sh start my_share
```

# resources

inspired by this thread http://forum.synology.com/enu/viewtopic.php?f=37&t=30242
