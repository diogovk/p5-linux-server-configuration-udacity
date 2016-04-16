#!/bin/bash


export DEBIAN_FRONTEND=noninteractive
aptitude upgrade -y
useradd -m grader
useradd -m catalog

aptitude install ufw
ufw default allow outgoing
ufw default deny incoming
ufw allow 2200/tcp
ufw allow ssh
ufw allow ntp
ufw allow http

aptitude install git -y
su - catalog -c "git clone https://github.com/diogovk/fullstack-webdev-catalog"

aptitude install apache2 -y
ufw enable
