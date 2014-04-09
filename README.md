# Introduction

This scripts synchronize each of your DLNA shared folders with Synology mediaserver Database, using synoindex utility

When you manage your files with commands like rsync/mv/cp/rm,..., DSM is unable to handle this methods, and refresh each of them

You'll find two scripts : 
 - synodlna-reindex.sh  : oneshot full synchronization between current shares content and database (one or all shares)
 - synodlna-reindex-inotify.sh  : synchronize 'on the fly' your current activity on your shares's files/directories with the database 

common : each of this scripts will detect defaults + user defined shares

# global requirement

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
# synodlna-reindex.sh 

## what does it do ?

this script is build to be runned manually, when you need to synchronize one or all your shared folder with mediaserver database

## usage

**embedded help**
```
./synodlna-reindex.sh
```

**show all your shares**

this option will list default + user defined shares (detected :-) )

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

## crontab

if you want to execute this task regulary,

you can find a crontab example + command to reload crond in **support/crontab/**

# synodlna-reindex-inotify.sh 

## what does it do ?

Once you've made a first synchronization of your database with synodlna-reindex.sh,

you can use this service to synchronize each of your added/removed files/directories for each DLNA shared folder

## requirements
  
### inotify-tools install

I've made an auto-installer for it :

**first, install some dependencies**
note : if some deps miss, you'll be notified by the installer


As root user :

```
ipkg install gcc make wget sudo
```

**define your admin user sudo**

```
visudo
```

add:

```
admin ALL(ALL) ALL
```

**now, you can install inotify-tools**

As admin user :

```
sh support/inotify-tools/inotify-tools_installer.sh
```

note: inotify-tools will be installed in path "/usr/local/inotify-tools/"

### prepare init.d service

To start synodlna-reindex-notify.sh on boot : 

```
sudo cp support/init.d/S99synodlna-reindex-inotify  /opt/etc/init.d/
sudo cp support/init.d/conf/synodlna-reindex-inotify  /opt/etc/default/
```

**Edit /opt/etc/default/synodlna-reindex-inotify**

you must define your absolute path to your **synodlna-reindex** installation

```
SYNODLNA_PATH=/volume1/homes/admin/script/synology/mediaserver/synodlna-reindex
```

## usage

the service should run as root :

under admin user, you can prefix following command with 'sudo'

**start the service**

```
/opt/etc/init.d/S99synodlna-reindex-inotify start
```

**show service status**

```
/opt/etc/init.d/S99synodlna-reindex-inotify status
```

**stop the service**

```
/opt/etc/init.d/S99synodlna-reindex-inotify stop
```

**show what's service doing**

```
/opt/etc/init.d/S99synodlna-reindex-inotify log
```

this option show the debug output log, containing activity on your shares handled by the script

# resources

inspired by : http://forum.synology.com/enu/viewtopic.php?f=37&t=30242

inotify-tools : https://github.com/rvoicilas/inotify-tools

