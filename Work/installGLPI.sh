if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Enter password for glpi database user"
read glpiPassword
#LAMP Installation
dnf install httpd php mariadb-server mariadb php-{gd,pdo,xml,mbstring,zip,mysqlnd,opcache,json} -y

#security stuff
setsebool -P httpd_unified on
#setsebool -P httpd_execmem 1
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --reload

#systemd stuff
systemctl enable --now httpd.service
systemctl enable --now mariadb.service

mysql_secure_installation

#cp /etc/httpd/conf/httpd.conf ~/httpd.conf.backup

#Database creation
mysql -u root -e "CREATE DATABASE glpi"
mysql -u root -e "GRANT ALL ON glpi.* TO 'glpi'@'localhost' IDENTIFIED BY '${glpiPassword}'"
mysql -u root -e "FLUSH PRIVILEGES"

#copy php config file
systemctl restart php-fpm



#GLPI installation
dnf install php-{curl,fileinfo,gd,json,mbstring,mysqli,session,zlib,simplexml,xml,intl} -y
dnf install php-{cli,domxml,ldap,openssl,xmlrpc,pecl-apcu} -y
#edit php conf file, perhaps
wget https://github.com/glpi-project/glpi/releases/download/9.5.3/glpi-9.5.3.tgz
tar -C /var/www/html/ -xvf glpi-9.5.3.tgz --strip-components=1 glpi/
cd /var/www/html
chown -R apache:apache /var/www/html
setsebool -P httpd_can_network_connect on
setsebool -P httpd_can_network_connect_db on
setsebool -P httpd_can_sendmail on

php bin/console glpi:system:check_requirements
read -p "Press any key to continue installation..."

echo "Database name:${RED}glpi${NC}"
echo "Database user:${RED}glpi${NC}"
echo "Database password:${RED}${glpiPassword}${NC}"
php bin/console db:install -p
