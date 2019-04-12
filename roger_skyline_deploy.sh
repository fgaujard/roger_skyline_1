#----------Menu Starter-------
echo "\033[32mHello, welcome to the automation setup of local website"
echo "Do you want setup this Debian VM ?\033[0m"
echo "\033[41mWarning !!! This automation was only test on Debian 9.8 in VM on the 42 Mac OS X\033[0m"
echo "\033[42;30mDo you want continue the setup ?\033[0m"
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
	service networking restart
	service ssh restart
	service sshd restart
	#--------Public Keys---------
	echo "You have to enter this command in your Mac OS X terminal :"
	echo "ssh-keygen -t rsa"
	echo "Now you have two files : << id_rsa >> and << id_rsa.pub >>"
	echo "Send id_rsa.pub with this command with the good username :"
	echo "ssh-copy-id -i id_rsa.pub user@10.12.15.2 -p 55555"
	echo "Did you have send the public key ? write : << yes i have >> "
	read yih
	while [ "$yih" -ne "yes i have" ]
	do
		echo "Error, write << yes i have >>"
		read yih
	done
	
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
	mkdir certs
	cd certs
	openssl genrsa -des3 -out server.key 1024 
	openssl req -new -key server.key -out server.csr
	cp server.key server.key.org
	openssl rsa -in server.key.org -out server.key
	openssl x509 -req -days -365 -in server.csr -signkey server.key -out server.crt
	cd ..
	mv certs /var/
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
elif [ "$yesno" = N ] || [ "$yesno" = n ]; then
	echo "\033[30;42m[ Annulation by quit ]\033[0m"
	exit 0
else
	echo "\033[41m[ Please answer by Y or N ]\033[0m"
	exit 0
fi
