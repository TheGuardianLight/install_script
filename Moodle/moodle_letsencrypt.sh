#!/bin/bash

# Finit l'installation de Moodle :

# Indique l'installation de Moodle
echo "Installation de Moodle..."

# Crée un fichier de configuration pour Moodle
echo "<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mariadb';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'localhost';
$CFG->dbname    = 'moodle';
$CFG->dbuser    = 'moodleuser';
$CFG->dbpass    = 'yourpassword';
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => '',
  'dbsocket' => '',
  'dbcollation' => 'utf8mb4_unicode_ci',
);

$CFG->wwwroot   = 'http://51.91.148.34/moodle';
$CFG->dataroot  = '/var/moodledata';
$CFG->admin     = 'admin';

$CFG->directorypermissions = 0777;

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!" > /var/www/html/moodle/config.php

# Indique l'installation de Let's Encrypt
echo "Installation de Let's Encrypt..."

# Installe le paquet snap
apt install -y snapd

# Installe le paquet core
snap install core

# Installe le paquet certbot
snap install --classic certbot

# Crée un lien symbolique pour certbot
ln -s /snap/bin/certbot /usr/bin/certbot

# Installe le certificat Let's Encrypt
certbot --apache

# Affiche un message pour indiquer que l'installation de Let's Encrypt est terminée
echo "Installation de Let's Encrypt terminé !"

# Indique où l'installation doit se finir
echo "Installation terminé ! Votre site est désormais configuré en https !"

# Indique la fin du script
exit 0
