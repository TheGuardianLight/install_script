#!/bin/bash

# Affiche un message pour indiquer le début de l'installation
echo "Installation des mises à jours et des dépendences..." 

# Met à jour le système avec apt, et installe les paquets apache2 et mariadb-server
apt update -y && apt full-upgrade -y
apt-get install -y apache2 mariadb-server 

# Installe divers paquets PHP et d'autres dépendances nécessaires à iTop
apt-get install -y php php-intl php-mysql php-ldap php-cli php-soap php-json php-curl graphviz php-xml php-gd php-zip libapache2-mod-php php-mbstring unzip 

# Affiche un message pour indiquer que l'installation est terminée
echo "Installation terminé !"

# Crée une nouvelle base de données et un nouvel utilisateur dans MariaDB
mysql -u root <<EOF
CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'moodleuser'@'localhost' IDENTIFIED BY 'yourpassword';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON moodle.* TO 'moodleuser'@'localhost';
FLUSH PRIVILEGES;
EOF
# Remplacer 'yourpassword' par le mot de passe souhaité

# Créer un fichier de répertoire pour les données de Moodle
mkdir /var/moodledata
chmod 777 /var/moodledata

# Affiche un message pour indiquer que la création de la base de données et de l'utilisateur est terminée
echo "Création de la base de donnée et de l'utilisateur terminé !"

# Indique le téléchargement de Moodle
echo "Téléchargement de Moodle..."

git clone -b MOODLE_402_STABLE git://git.moodle.org/moodle.git /var/www/html/moodle

# Affiche un message pour indiquer que le téléchargement de Moodle est terminé
echo "Téléchargement de Moodle terminé !"

# Indique l'installation d'Apache
echo "Installation d'Apache..."

service apache2 start
systemctl enable apache2

# Crée un fichier de configuration pour Apache
echo "<VirtualHost *:80>
ServerAdmin veivneorul@neodraco.fr
DocumentRoot /var/www/html/moodle
ServerName moodle.neodraco.fr
ServerAlias www.moodle.neodraco.fr
ErrorLog /var/log/apache2/moodle.neodraco.fr-error_log
CustomLog /var/log/apache2/moodle.neodraco.fr-access_log common
</VirtualHost>" > /etc/apache2/sites-available/moodle.conf

# Active le fichier de configuration
a2ensite moodle.conf

# Active le module Apache mod_rewrite
a2enmod rewrite

# Redémarre Apache
systemctl restart apache2

# Affiche un message pour indiquer que la configuration d'Apache est terminée
echo "Configuration d'Apache terminé !"

# Indique l'installation de PHP
echo "Installation de PHP..."

# Crée un fichier de configuration pour PHP
echo "file_uploads = On
allow_url_fopen = On
short_open_tag = On
memory_limit = 256M
upload_max_filesize = 100M
max_execution_time = 360
max_input_vars = 5000
date.timezone = Europe/Paris" > /etc/php/8.1/apache2/conf.d/moodle.ini

# Redémarre Apache
systemctl restart apache2

# Affiche un message pour indiquer que la configuration de PHP est terminée
echo "Configuration de PHP terminé !"

# Configuration du cron
echo "Configuration du cron..."

# Crée un fichier de configuration pour le cron
echo "* * * * * /usr/bin/php /var/www/html/moodle/admin/cli/cron.php >/dev/null" > /etc/cron.d/moodle

# Affiche un message pour indiquer que la configuration du cron est terminée
echo "Configuration du cron terminé !"

# Affiche un message pour indiquer que l'installation de Moodle est terminée
echo "Installation de Moodle terminé !"

# Modifie les permission du fichier letsencrypt.sh
chmod +x moodle_letsencrypt.sh

# Indique où l'installation doit se finir
echo "Installation terminé !"
echo "Rendez-vous sur http://<IP>/moodle pour terminer l'installation de Moodle"

# Indique l'adresse IP du serveur
echo "Adresse IP du serveur :"
hostname -I

# Indique la fin du script
exit 0
