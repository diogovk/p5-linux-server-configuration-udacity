# p5-linux-server-configuration-udacity

# Access information

Webapp URL: http://52.26.115.20/
Host: 52.26.115.20
Users: catalog grader
Authentication: RSA Key based

# Software installed

ufw - Uncomplicated Firewall
git - Source Code Management and Distribution
postgresql - Open Source Database used by the webapp
apache2 - Web Server
libapache2-mod-wsgi - WSGI support for Apache

### Webapp dependencies

python-psycopg2 python-sqlalchemy python-bs4
python-pip Flask oauth2client requests
Flask-Migrate dicttoxml flask-wtf

### Webapp information

The webapp was downloaded from https://github.com/diogovk/fullstack-webdev-catalog

# Configurations made

## SSH

- Changed port to 2200
- Disabled root login
- Made sure remote logon with password is disabled

## UFW

- Block all incoming connections by default
- Allow all outgoing connections by default
- Allow port 2200(ssh) 80(http) and 123(ntp)

## Users
- User grader created
- Grant sudo to grader
- User catalog created
- Postgres permissions granted to catalog
- Password set up for both users
- Postgres password set up for catalog

## Postgres
- Make sure only connections from localhost are allowed

## Timezone
- Configure timezone to UTC

## Apache
- Enable WSGI for our app
- Permissions to apache's user were given in the webapp working directory
- Created a few symbolic links in apache's working directory pointing to the webapp's directory

## Web Catalog App
- Created Database and set it up
- Seeded data
- Postgresql set to connect to localhost using catalog's credentials
- Created a WSGI file

# Resources
https://mediatemple.net/community/products/dv/204643810/how-do-i-disable-ssh-login-for-the-root-user
http://stackoverflow.com/questions/714915/using-the-passwd-command-from-within-a-shell-script
http://flask.pocoo.org/docs/0.10/deploying/mod_wsgi/
http://unix.stackexchange.com/questions/140734/configure-localtime-dpkg-reconfigure-tzdata
