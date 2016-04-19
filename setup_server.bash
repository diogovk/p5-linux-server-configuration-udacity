#!/bin/bash

# This script is intended to be idempotent, which mean you could
# run it more than once and obtain the same result

export DEBIAN_FRONTEND=noninteractive
apt-get -qqy update
aptitude upgrade -y
useradd -m grader
passwd grader << EOF
Mk7z73Pkk
Mk7z73Pkk
EOF

grep -q ^grader /etc/sudoers || {
    echo 'grader ALL=(ALL:ALL) ALL' >> /etc/sudoers
}

useradd -m catalog
passwd catalog << EOF
Mk7z73Pkk
Mk7z73Pkk
EOF

aptitude install ufw
ufw default allow outgoing
ufw default deny incoming
ufw allow 2200/tcp
#ufw allow ssh
ufw allow ntp
ufw allow http

aptitude install git -y
su - catalog -c "git clone https://github.com/diogovk/fullstack-webdev-catalog"

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
su - postgres -c "psql -c \"ALTER USER catalog WITH PASSWORD 'mkbx00k77P'\""
sed -i "s/^app.config\['SQLALCHEMY_DATABASE_URI'\]\s*=.*/app.config['SQLALCHEMY_DATABASE_URI'] = 'postgres:\/\/catalog:mkbx00k77P@localhost\/webcatalog'/" \
/home/catalog/fullstack-webdev-catalog/app.py
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

cat > /var/www/html/web_catalog.wsgi << \EOF
import sys
import os
sys.path.insert(0, '/home/catalog/fullstack-webdev-catalog')
os.chdir('/var/www/html')

from web_catalog import app as application
EOF


chown -R www-data:www-data /home/catalog/fullstack-webdev-catalog/*
chown www-data:www-data /home/catalog/fullstack-webdev-catalog

cd /var/www/html
ln -s /home/catalog/fullstack-webdev-catalog/static
ln -s /home/catalog/fullstack-webdev-catalog/client_secret_webcatalog.json
ln -s /home/catalog/fullstack-webdev-catalog/fb_client_secret_webcatalog.json
ln -s /home/catalog/fullstack-webdev-catalog/templates

service apache2 restart

sed -i 's/^Port\s.*/Port 2200/' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin\s.*/PermitRootLogin no/' /etc/ssh/sshd_config
service ssh restart




ufw enable <<< y

echo "-----------------------------
Process finished.
Be sure to restart the server if needed (i.e. kernel upgrade)"
