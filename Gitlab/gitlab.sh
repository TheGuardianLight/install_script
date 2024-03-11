#!/bin/sh

# update the system
apt-get update -y && sudo apt-get upgrade -y

# install the dependencies
apt-get install -y curl openssh-server ca-certificates tzdata perl postfix

wget https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh
chmod +x script.deb.sh
os=ubuntu dist=lunar ./script.deb.sh


 sudo EXTERNAL_URL="https://git.neodraco.fr" apt-get install gitlab-ee
 # List available versions: apt-cache madison gitlab-ee
 # Specifiy version: sudo EXTERNAL_URL="https://gitlab.example.com" apt-get install gitlab-ee=16.2.3-ee.0
 # Pin the version to limit auto-updates: sudo apt-mark hold gitlab-ee
 # Show what packages are held back: sudo apt-mark showhold

