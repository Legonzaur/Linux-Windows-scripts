if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

RED='\033[0;31m'
NC='\033[0m' # No Color


read -p "Enter password for glpi database user" glpiPassword

read -p "Enter MySQL root password (leave empty for none)" mysqlPasword
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

while true; do
    read -p "Do you wish to run mysql_secure_installation? [y(Recommended)/n]" yn
    case $yn in
        [Yy]* ) mysql_secure_installation; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

#cp /etc/httpd/conf/httpd.conf ~/httpd.conf.backup

#Database creation
echo "1/3 : Enter MYSQL root password"
mysql -u root -p "${mysqlPassword}" -e "CREATE DATABASE glpi"
echo "2/3 : Enter MYSQL root password"
mysql -u root -p "${mysqlPassword}" -e "GRANT ALL ON glpi.* TO 'glpi'@'localhost' IDENTIFIED BY '${glpiPassword}'"
echo "3/3 : Enter MYSQL root password"
mysql -u root -p "${mysqlPassword}" -e "FLUSH PRIVILEGES"

#copy php config file
systemctl restart php-fpm



#GLPI installation
dnf install php-{curl,fileinfo,gd,json,mbstring,mysqli,session,zlib,simplexml,xml,intl} -y
dnf install php-{cli,domxml,ldap,openssl,xmlrpc,pecl-apcu} -y
#edit php conf file, perhaps

wget https://github.com/glpi-project/glpi/releases/download/9.5.3/glpi-9.5.3.tgz
mkdir /var/www/html/glpi
tar -C /var/www/html/glpi -xvf glpi-9.5.3.tgz --strip-components=1 glpi/

wget https://github.com/pluginsGLPI/genericobject/releases/download/2.9.2/glpi-genericobject-2.9.2.tar.bz2
mkdir /var/www/html/glpi/plugins
tar -C /var/www/html/glpi/plugins -xvf glpi-genericobject-2.9.2.tar.bz2

cd /var/www/html/glpi
chown -R apache:apache /var/www/html
setsebool -P httpd_can_network_connect on
setsebool -P httpd_can_network_connect_db on
setsebool -P httpd_can_sendmail on

php bin/console glpi:system:check_requirements
read -p "Press any key to continue installation..."

echo -e "Database name:${RED}glpi${NC}"
echo -e "Database user:${RED}glpi${NC}"
echo -e "Database password:${RED}${glpiPassword}${NC}"
php bin/console db:install -p
