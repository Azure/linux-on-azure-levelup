#!/bin/bash

# Update system packages
sudo yum update -y

# Install Apache (httpd) and PHP with PostgreSQL support

sudo yum install -y httpd
sudo yum install -y php
sudo yum install -y php-xml
sudo yum install -y php-pgsql

# Enable and start Apache service
sudo systemctl enable httpd
sudo systemctl start httpd

# Set proper permissions on the web root directory
#sudo chown -R apache:apache /var/www/html/
#sudo chmod -R 755 /var/www/html/

# Open firewall ports for HTTP (80), HTTPS (443), and PostgreSQL (5432)
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --permanent --add-port=5432/tcp

# Reload the firewall to apply the changes
sudo firewall-cmd --reload

# Restart Apache service to ensure all changes take effect
sudo systemctl restart httpd

# Output success message
echo "Apache with PHP installed successfully. Firewall ports 80, 443, and 5432 are open."
echo "Access the index.php page from your browser to test PostgreSQL connection."
