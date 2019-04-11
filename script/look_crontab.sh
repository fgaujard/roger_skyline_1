#!/ bin/bash
subject="[ Crontab modified ]"
file="/var/log/modified.crontab"
look="/etc/crontab"
cmd="$(sudo md5sum $look)"
if [ ! -f $file ]; then
	echo "$cmd" sudo > $file
fi

if [ "$cmd" != "$(cat $file)" ]; then
	echo "$cmd" sudo > $file
	mail -s "$subject" root@localhost < $look
fi
