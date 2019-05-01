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
	service sudo restart
	exit
	#-----fix ip and netmask-----
	sudo rm -f /etc/network/interfaces
	sudo mv files/interfaces /etc/network/
	sudo rm -f /etc/ssh/sshd_config
	sudo mv files/sshd_config /etc/ssh/
	sudo service networking restart
	sudo service sshd restart
	#--------Public Keys---------
	echo "You have to enter this command in your Mac OS X terminal :"
	echo "ssh-keygen -t rsa"
	echo "Now you have two files : << id_rsa >> and << id_rsa.pub >>"
	echo "Send id_rsa.pub with this command with the good username :"
	echo "ssh-copy-id -i id_rsa.pub $usr@10.12.15.2 -p 55555"
	echo "Did you have send the public key ? write : << yes i have >> "
	read yih
	while [ "$yih" -ne "yes i have" ]
	do
		echo "Error, write << yes i have >>"
		read yih
	done
	sudo rm -f /etc/ssh/ssh_config
	sudo mv files/files2/sshd_config
	sudo service sshd restart
	#-----------firewall--------
	sudo iptables -F
	sudo iptables -X
	sudo iptables -P INPUT DROP
	sudo iptables -P OUTPUT DROP
	sudo iptables -P FORWARD DROP
	sudo iptables -A INPUT -p tcp -i enp0s3 --dport 55555 -j ACCEPT
	sudo iptables -A OUTPUT -p tcp -o enp0s3 --dport 55555 -j ACCEPT
	sudo iptables -A INPUT -p tcp -i enp0s3 --dport 80 -j ACCEPT
	sudo iptables -A OUTPUT -p tcp -o enp0s3 --dport 80 -j ACCEPT
	sudo iptables -A INPUT -p tcp -i enp0s3 --dport 443 -j ACCEPT
	sudo iptables -A OUTPUT -p tcp -o enp0s3 --dport 443 -J ACCEPT
	sudo iptables -I INPUT 2 -i lo -j ACCEPT
	sudo iptables -I OUTPUT 2 -o lo -j ACCEPT
	sudo iptables -A INPUT -i enp0s3 -p icmp -j ACCEPT
	sudo iptables -A OUTPUT -o enp0s3 -p icmp -j ACCEPT
	sudo iptables-save > /etc/iptables.rules
	sudo rm -f /etc/network/interfaces
	sudo mv files/files2/interfaces
	sudo service networking restart
	sudo service sshd restart
	#----------fail2ban----------
	sudo rm -f
	sudo mv
	#---------portsentry---------
	sudo rm -f /etc/default/portsentry
	sudo mv files/portsentry /etc/default/
	sudo rm -f /portsentry/portsentry.conf
	sudo mv files/portsentry.conf /etc/portsentry
	sudo service portsentry restart
	#-------disable service-------
	sudo systemctl disable console-setup.service
	sudo systemctl disable keyboard-setup.service
	sudo systemctl disable apt-daily.timer
	sudo systemctl disable apt-daily-upgrade.timer
	sudo systemctl disable syslog.service
	#----------script cron--------
	sudo mv script /
	sudo rm -f /etc/crontab
	sudo mv files/crontab /etc/crontab
	#------------web part---------
	sudo rm -f /var/www/html/index.html
	sudo mv web/* /var/www/html
	sudo mkdir certs
	sudo cd certs
	sudo openssl genrsa -des3 -out server.key 1024 
	sudo openssl req -new -key server.key -out server.csr
	sudo cp server.key server.key.org
	sudo openssl rsa -in server.key.org -out server.key
	sudo openssl x509 -req -days -365 -in server.csr -signkey server.key -out server.crt
	sudo cd ..
	sudo mv certs /var/
	sudo rm -f /etc/apache2/sites-available/default-ssl.conf
	sudo mv files/default-ssl.conf /etc/apache2/sites-available/
	sudo rm -f /etc/apache2/sites-available/000-default.conf
	sudo mv files/000-default.conf /etc/apache2/sites-availables/
	sudo a2enmod ssl
	sudo a2enmod headers
	sudo a2ensite default-ssl
	sudo a2enconf ssl-params
	sudo systemctl reload apache2
	#---------Reboot sys----------
	sudo reboot
elif [ "$yesno" = N ] || [ "$yesno" = n ]; then
	echo "\033[30;42m[ Annulation by quit ]\033[0m"
	exit 0
else
	echo "\033[41m[ Please answer by Y or N ]\033[0m"
	exit 0
fi
