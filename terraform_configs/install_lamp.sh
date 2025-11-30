#!/bin/bash
# install_lamp.sh

# Update system packages
sudo dnf update -y

# Install Apache, MySQL, PHP and required modules
sudo dnf install -y httpd mariadb105-server php php-mysqli php-pdo php-xml php-mbstring php-json

# Start and enable Apache service
sudo systemctl start httpd
sudo systemctl enable httpd

# Start and enable MariaDB (MySQL) service
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Optional: Secure MySQL installation (basic steps - consider a more secure approach for production)
# This sets a root password to 'mypassword' for demonstration
sudo mysql -e "UPDATE mysql.user SET Authentication_string=PASSWORD('mypassword') WHERE User='root';"
sudo mysql -e "UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root';"
sudo mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Place a sample PHP application file in the Apache web root
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php
echo "<h1>Terraform LAMP Stack Deployed!</h1>" | sudo tee /var/www/html/index.html
