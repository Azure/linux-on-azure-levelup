#!/bin/bash

# Update system packages
sudo yum update -y

# Install PostgreSQL repository
sudo yum install -y https://download.postgresql.org/pub/repos/yum/13/redhat/rhel-7-x86_64/pgdg-centos13-13-2.noarch.rpm

# Install PostgreSQL server
sudo yum install -y postgresql13-server postgresql13-contrib

# Initialize PostgreSQL database
sudo /usr/pgsql-13/bin/postgresql-13-setup initdb

# Enable and start PostgreSQL service
sudo systemctl enable postgresql-13
sudo systemctl start postgresql-13

# Set PostgreSQL to allow local password authentication
sudo sed -i "s/ident/md5/" /var/lib/pgsql/13/data/pg_hba.conf

# Restart PostgreSQL to apply changes
sudo systemctl restart postgresql-13

# Switch to the PostgreSQL user to create a new user
sudo -u postgres psql -c "CREATE USER pgsqlad WITH PASSWORD '6XxJzWjDTtPt';"

# Grant login and privileges to the new user
sudo -u postgres psql -c "ALTER USER pgsqlad WITH LOGIN;"

# Output success message
echo "PostgreSQL installed successfully. User 'pgsqlad' created with access to PostgreSQL."
