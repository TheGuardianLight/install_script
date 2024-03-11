#!/bin/bash

# Link of the download page : https://community.limesurvey.org/downloads/

apt update && apt upgrade -y
apt install mariadb-server apache2 php php-mysql php-gd php-xml php-mbstring php-zip php-curl php-ldap php-imap php-bcmath php-intl php-xmlrpc php-soap unzip -y

# Download Limesurvey
wget https://download.limesurvey.org/latest-master/limesurvey6.4.11+240304.zip
unzip limesurvey6.4.11+240304.zip -d /var/www/
chown -R www-data:www-data /var/www/limesurvey

echo "Veuillez entrer le nom de la base de données :"
read database
echo "Veuillez entrer le nom de l'utilisateur de la base de données :"
read database_user
echo "Veuillez entrer le mot de passe de la base de données :"
read -s database_mdp
echo "Veuillez entrer votre adresse :"
read your_address


# Create database
mysql-secure-installation
mysql -u root -e "CREATE DATABASE $database;"
mysql -u root -e "CREATE USER '$database_user'@'localhost' IDENTIFIED BY '$database_mdp';"
mysql -u root -e "GRANT ALL PRIVILEGES ON $database.* TO '$database_user'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

# Create Apache2 configuration
echo "<VirtualHost *:80>
    ServerName $your_address
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/limesurvey
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" > /etc/apache2/sites-available/limesurvey.conf

a2ensite limesurvey
a2enmod rewrite
systemctl restart apache2
systemctl enable apache2

# Clean
rm limesurvey6.4.11+240304.zip

# End
echo "Limesurvey is now available at http://$your_address"
echo "Database: $database"
echo "User: $database_user"
echo "Password: $database_mdp"
echo "Please change the password after the first connection"
echo "Don't forget to secure your server with a SSL certificate"
echo "You can use Certbot to get a free SSL certificate"
echo "Enjoy your survey !"

# End of the script
exit 0
