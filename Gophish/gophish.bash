# Vérifie si le script est lancé avec les permissions administrateurs
echo "Vérification des permissions administrateurs..."
if [ $EUID -ne 0 ]; then
    echo "Vous devez lancer ce script avec les permissions administrateurs"
    exit 1
    else echo "Vous avez les permissions administrateurs"
fi

# Mise à jour des paquets et installation des dépendances
echo "Voulez vous mettre à jour les paquets avant d'installer les dépendances de GoPhish ? (y/n)"
read update
if [ $update = "y" ]; then
    echo "Mise à jour des paquets puis installation des dépendances..."
    apt update && apt upgrade -y && apt install golang sqlite3 apache2 zip curl -y
    else
    echo "Vous n'avez pas choisi de mettre à jour les paquets."
    echo "Installation des dépendances..."
    apt install golang sqlite3 apache2 zip curl -y
fi

# Installation de GoPhish
echo "Installation de GoPhish..."
cd /opt
mkdir gophish
wget https://github.com/gophish/gophish/releases/download/v0.12.1/gophish-v0.12.1-linux-64bit.zip
unzip gophish-v0.12.1-linux-64bit.zip -d /opt/gophish

# Création et configuration de la base de données
echo "Création et configuration de la base de données sqlite..."
cd /opt/gophish

# Arrête le service d'Apache et le désactive
echo "Arrêt du service d'Apache et désactivation..."
systemctl stop apache2
systemctl mask apache2

# Question sur la configuration du serveur
echo "Veuillez entrer l'adresse IP de votre serveur d'Administration GoPhish :"
read ip_admin
echo "Veuillez entrer l'adresse IP de votre serveur de Phishing GoPhish :"
read ip_phish
echo "Voulez vous utiliser un certificat SSL pour votre serveur d'administration ? (y/n)"
read admin_ssl
if [ $admin_ssl = "y" ]; then
    admin_ssl_use=true
    echo "Voulez vous utiliser la configuration SSL par défaut ? (y/n)"
    read admin_ssl_default
    if [ $admin_ssl_default = "y" ]; then
        admin_cert="/opt/gophish/gophish_admin.crt"
        admin_key="/opt/gophish/gophish_admin.key"
        else
        echo "Veuillez entrer le chemin vers votre certificat SSL :"
        read admin_cert
        echo "Veuillez entrer le chemin vers votre clé SSL :"
        read admin_key
    fi
    else
    echo "Vous n'utiliserez pas de certificat SSL"
    admin_ssl_use=false
fi
echo "Voulez vous utiliser un certificat SSL pour votre serveur de phishing ? (y/n)"
read phish_ssl
if [ $phish_ssl = "y" ]; then
    phish_ssl_use=true
    echo "Veuillez entrer le chemin vers votre certificat SSL :"
    read phish_cert
    echo "Veuillez entrer le chemin vers votre clé SSL :"
    read phish_key
    else
    echo "Vous n'utiliserez pas de certificat SSL"
    phish_ssl_use=false
fi
echo "Veuillez entrer une adresse mail de contact :"
read contact_mail

# Création du fichier de configuration
echo "Création du fichier de configuration..."
rm /opt/gophish/config.json
cd /opt/gophish
touch config.json
cat << EOF > config.json
{
    "admin_server": {
        "listen_url": "$ip_admin:3333",
        "use_tls": $admin_ssl_use,
        "cert_path": "$admin_cert",
        "key_path": "$admin_key",
        "trusted_origins": []
    },
    "phish_server": {
        "listen_url": "$ip_phish:80",
        "use_tls": $phish_ssl_use,
        "cert_path": "$phish_cert",
        "key_path": "$phish_key"
    },
    "db_name": "sqlite3",
    "db_path": "gophish.db",
    "migrations_prefix": "db/db_",
    "contact_address": "$contact_mail",
    "logging": {
        "filename": "gophish.log",
        "level": "debug"
    }
}
EOF

# Met à jours les permissions du fichier de configuration
echo "Mise à jour des permissions du fichier de configuration..."
chmod 0640 /opt/gophish/config.json

# Démarrage de GoPhish
echo "Démarrage de GoPhish..."
echo "Note: Lors du premier démarrage, le nom d'utilisateur et le mot de passe seront indiqué dans les lignes suivantes."
echo "Une fois le mot de passe changé, faites ctrl + c pour arrêter GoPhish et continuer le script."
echo "Notez également que le serveur tournera en local. Vous devrez modifier le fichier config.json à votre guise par la suite."
cd /opt/gophish
chmod +x gophish
./gophish

# Création du service GoPhish
echo "Création du service GoPhish..."
useradd -r gophish -M -d /opt/gophish/
cd /etc/systemd/system
touch gophish.service
cat << EOF > gophish.service
[Unit]
Description=Gophish, an open-source phishing toolkit
Documentation=https://getgophish.com/documentation/
After=network.target

[Service]
WorkingDirectory=/opt/gophish
User=gophish
Environment='STDOUT=/var/log/gophish/gophish.log'
Environment='STDERR=/var/log/gophish/gophish.log'
PIDFile=/var/run/gophish
ExecStart=/bin/sh -c "/opt/gophish/gophish"

[Install]
WantedBy=multi-user.target
EOF

mkdir /var/log/gophish
chown -R gophish:gophish /opt/gophish/ /var/log/gophish/
setcap cap_net_bind_service=+ep /opt/gophish/gophish
systemctl daemon-reload
systemctl enable --now gophish


echo "Installation de GoPhish terminée !"
echo "Pour lancer GoPhish, utilisez la commande 'systemctl start gophish'"