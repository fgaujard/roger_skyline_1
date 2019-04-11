#!/bin/bash
logfile="/var/log/update_script.log"
echo "Upgrade to" >> $logfile
date >> $logfile
apt-get update -y >> $logfile
apt-get upgrade -y >> $logfile
echo "\n\n" >> $logfile

