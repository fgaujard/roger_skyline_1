#----------Menu Starter-------
echo "\033[32mHello, welcome to the automation setup of local website"
echo "Do you want setup this Debian VM ?"
echo "Warning !!! This automation was only test on Debian 9.8 !"
echo "Do you want continue the setup ?\033[0m"
read yesno
if [ "$yesno" = Y ] || [ "$yesno" = y ]; then
	#--------Package install------
	su
	apt-get install sudo vim iptables portsentry fail2ban apache2 mailutils -y
	apt-get update -y && apt-get upgrade -y
	#------sudoers usr-------
	usr=$(who | cut -f1 -d ' ')
	adduser $usr sudo
	usermod -aG sudo $usr
	#-----fix ip and netmask-----
	rm -f /etc/network/interfaces
	mv files/interfaces /etc/network/
	rm -f /etc/ssh/sshd_config
	mv files/sshd_config /etc/ssh/
	#-----------firewall--------
	iptables -F
	iptables -X
	iptables -P INPUT DROP
	iptables -P OUTPUT DROP
	iptables -P FORWARD DROP
	iptables -A INPUT -p tcp -i enp0s3 --dport 55555 -j ACCEPT
	iptables -A OUTPUT -p tcp -o enp0s3 --dport 55555 -j ACCEPT
	iptables -A INPUT -p tcp -i enp0s3 --dport 80 -j ACCEPT
	iptables -A OUTPUT -p tcp -o enp0s3 --dport 80 -j ACCEPT
	iptables -A INPUT -p tcp -i enp0s3 --dport 443 -j ACCEPT
	iptables -A OUTPUT -p tcp -o enp0s3 --dport 443 -J ACCEPT
	iptables -I INPUT 2 -i lo -j ACCEPT
	iptables -I OUTPUT 2 -o lo -j ACCEPT
	iptables -A INPUT -i enp0s3 -p icmp -j ACCEPT
	iptables -A OUTPUT -o enp0s3 -p icmp -j ACCEPT
	iptables-save > /etc/iptables.rules
	service networking restart
	service ssh restart
	#----------fail2ban----------
	#---------portsentry---------
	rm -f /etc/default/portsentry
	mv files/portsentry /etc/default/
	rm -f /portsentry/portsentry.conf
	mv files/portsentry.conf /etc/portsentry
	service portsentry restart
	#-------disable service-------
	systemctl disable console-setup.service
	systemctl disable keyboard-setup.service
	systemctl disable apt-daily.timer
	systemctl disable apt-daily-upgrade.timer
	systemctl disable syslog.service
	#----------script cron--------
	mv script /
	rm -f /etc/crontab
	mv files/crontab /etc/crontab
	#------------web part---------
	rm -f /var/www/html/index.html
	mv web/* /var/www/html
	rm -f /etc/apache2/sites-available/default-ssl.conf
	mv files/default-ssl.conf /etc/apache2/sites-available/
	rm -f /etc/apache2/sites-available/000-default.conf
	mv files/000-default.conf /etc/apache2/sites-availables/
	a2enmod ssl
	a2enmod headers
	a2ensite default-ssl
	a2enconf ssl-params
	systemctl reload apache2
	#---------Reboot sys----------
	reboot
elif [ "$yesno" = N ] || ["$yesno" = n ]; then
	echo "\033[30;42m[ Annulation by quit ]\033[0m"
	exit 0
else
	echo "\033[41m[ Please answer by Y or N ]\033[0m"
	exit 0
fi
