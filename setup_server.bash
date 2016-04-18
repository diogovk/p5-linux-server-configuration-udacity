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

apt-get -qqy update
apt-get -qqy install postgresql python-psycopg2
apt-get -qqy install python-sqlalchemy python-bs4
apt-get -qqy install python-pip
pip2 install Flask
pip2 install oauth2client
pip2 install requests
pip2 install Flask-Migrate
pip2 install dicttoxml
pip2 install flask-wtf
su - postgres -c 'createuser -dRS catalog'
su - postgres -c "psql -c \"ALTER USER catalog WITH PASSWORD 'mkbx00k'\""
su - catalog -c 'createdb'
su - catalog -c 'createdb webcatalog'
cd /home/catalog/fullstack-webdev-catalog
su catalog -c 'python2 migrator.py db upgrade'

# Seed database if not categories are found
su catalog -c '
is_seeded_database() {
    psql -t -d webcatalog -c "select 1 from category limit 1" | grep -q .
}
if is_seeded_database; then
    echo "Skipping database seed"
else
    python2 seed_database.py
fi
'

echo 'Etc/UTC' > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

aptitude install libapache2-mod-wsgi apache2 -y

grep -q WSGIScriptAlias /etc/apache2/sites-enabled/000-default.conf || {
    sed -i 's/<\/VirtualHost>/\tWSGIScriptAlias \/ \/var\/www\/html\/webcatalog.wsgi\n<\/VirtualHost>/g' \
        /etc/apache2/sites-enabled/000-default.conf
}

chown -R www-data:www-data /home/catalog/fullstack-webdev-catalog/*


service apache2 restart

sed -i 's/^Port\s.*/Port 2200/' /etc/ssh/sshd_config
service ssh restart



grep -q ^grader /etc/sudoers || {
    echo 'grader ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
}

ufw enable <<< y

echo "-----------------------------
Process finished.
Be sure to restart the server if need (i.e. kernel upgrade)"
