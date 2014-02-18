# Introduction

This script synchronize each of your DLNA shared folders with Synology mediaserver Database

When you send your files over SSH, DSM is unable to refresh each of them
you can start reindex on one or all shares

# resources

inspired by this thread http://forum.synology.com/enu/viewtopic.php?f=37&t=30242

# requirement

 - SSH access to your Synology NAS
 - IPKG : see http://forum.synology.com/wiki/index.php/Overview_on_modifying_the_Synology_Server%2C_bootstrap%2C_ipkg_etc#What_do_I_need_to_do

 **install bash 3.x**
 ipkg install bash
 
# usage

you can override your RAID volume :

cp config.sh.dist config.sh
vi config.sh
VOLUME_ROOT=...

**show all your shares**

./synodlna-reindex.sh list

**reindex all shares**

./synodlna-reindex.sh start all

**reindex one share**

./synodlna-reindex.sh start my_share


