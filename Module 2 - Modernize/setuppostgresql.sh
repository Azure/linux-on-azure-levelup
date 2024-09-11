#!/bin/bash

# Update system packages
sudo yum update -y

# Install PostgreSQL server

sudo yum install -y postgresql-server postgresql-contrib 

# Initialize PostgreSQL database

sudo postgresql-setup initdb

# Enable and start PostgreSQL service

sudo systemctl start postgresql
sudo systemctl enable postgresql

# Set PostgreSQL to allow local password authentication
# sudo sed -i "s/ident/md5/" /var/lib/pgsql/data/pg_hba.conf

# Restart PostgreSQL to apply changes
sudo systemctl restart postgresql

curl -o /northwind_postgresql.sql https://raw.githubusercontent.com/Azure/linux-on-azure-levelup/main/Module%202%20-%20Modernize/northwind_postgresql.sql

chmod 644 /northwind_postgresql.sql 

# Output success message
echo "PostgreSQL installed successfully. Database initialized and service started."
