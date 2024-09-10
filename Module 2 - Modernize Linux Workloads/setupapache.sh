#!/bin/bash

# Update system packages
sudo yum update -y

# Install Apache (httpd)
sudo yum install -y httpd

# Enable and start Apache service
sudo systemctl enable httpd
sudo systemctl start httpd


# Output success message
echo "Apache installed successfully."