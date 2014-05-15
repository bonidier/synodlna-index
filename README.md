# Introduction

This scripts synchronize each of your DLNA shared folders with Synology mediaserver Database, using synoindex utility

When you manage your files with commands like rsync/mv/cp/rm,..., DSM is unable to handle this methods, and refresh each of them

You'll find two scripts : 
 - synodlna-reindex.sh  : oneshot full synchronization between current shares content and database (one or all shares)
 - synodlna-reindex-inotify.sh  : synchronize 'on the fly' your current activity on your shares's files/directories with the database 

common : each of this scripts will detect defaults + user defined shares

# global requirement

**SSH access**

enable SSH access to your Synology NAS under DSM web interface

**IPKG bootstrap**

 forum.synology.com/wiki/index.php/Overview_on_modifying_the_Synology_Server%2C_bootstrap%2C_ipkg_etc#Installing_compiled.2Fbinary_programs_using_ipkg

in short :

 - get and exec the XSH file for your CPU
 - if your DSM is >= 4.x, on the top of  /root/.profile comment PATH lines
 - reboot your NAS
 - run "ipkg update" to get packages database

# installation

## sudo management

under "root" user :

```
ipkg install sudo
```

**define your admin user sudo**

```
visudo
```

add:

```
admin ALL=(ALL) ALL
```

## synodlna dependencies

**under "admin" user**

**get this project**

```
sudo ipkg install git
git clone https://github.com/bonidier/synodlna-index.git synodlna-index
cd synodlna-index
```


**the Makefile simplify the IPKG packages dependencies installation**

```
sudo ipkg install make
make ipkg
```

**Installer for inotify-tools, required by synodlna-reindex-inotify.sh**

```
make inotify-tools
```

note: inotify-tools will be installed in path "/usr/local/inotify-tools/"

## prepare init.d service

To start synodlna-reindex-notify.sh on boot :

**auto-install service to /opt/etc/init.d directory**

this will copy service if needed, as the linked configuration file

```
make service
```

**edit /opt/etc/default/synodlna-reindex-inotify**

you must define your absolute path to your **synodlna-reindex** installation

```
SYNODLNA_PATH=/volume1/homes/admin/script/synology/mediaserver/synodlna-reindex
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

