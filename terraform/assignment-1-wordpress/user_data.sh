#!/bin/bash
set -e

# What: Update Ubuntu package list
# Why: The server needs the latest package information before installing software
apt-get update -y

# What: Install WordPress dependencies
# Why: WordPress needs Apache, MariaDB, PHP, and extra PHP modules to work properly
apt-get install -y apache2 mariadb-server php php-mysql php-curl php-gd php-mbstring php-xml php-soap php-intl php-zip unzip curl

# What: Start and enable Apache and MariaDB
# Why: Apache serves the website, and MariaDB stores WordPress data
systemctl enable apache2
systemctl enable mariadb
systemctl start apache2
systemctl start mariadb

# What: Set database details for WordPress
# Why: WordPress needs a database name, user, and password
DB_NAME="wordpress"
DB_USER="wpuser"
DB_PASS="StrongPass123!"

# What: Create the WordPress database and user
# Why: WordPress needs permission to store and access site data
mysql -u root <<SQL
CREATE DATABASE IF NOT EXISTS ${DB_NAME} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
SQL

# What: Download WordPress
# Why: WordPress is the website application Apache will serve
cd /tmp
curl -L -o wordpress.tar.gz https://wordpress.org/latest.tar.gz
tar -xzf wordpress.tar.gz

# What: Move WordPress files into Apache's web directory
# Why: Apache serves website files from /var/www/html by default
rm -rf /var/www/html/*
cp -r wordpress/* /var/www/html/

# What: Create the WordPress configuration file
# Why: WordPress uses wp-config.php to connect to the database
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# What: Add database details into wp-config.php
# Why: This tells WordPress which database, username, and password to use
sed -i "s/database_name_here/${DB_NAME}/" /var/www/html/wp-config.php
sed -i "s/username_here/${DB_USER}/" /var/www/html/wp-config.php
sed -i "s/password_here/${DB_PASS}/" /var/www/html/wp-config.php

# What: Set correct ownership and permissions
# Why: Apache runs as www-data and needs permission to serve WordPress files
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# What: Restart Apache
# Why: Refreshes the web server after WordPress has been installed and configured
systemctl restart apache2