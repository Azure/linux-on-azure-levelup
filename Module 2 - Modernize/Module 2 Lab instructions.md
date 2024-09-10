# Module 2 - Apache and Postgresql server modernization

Overview

In this workshop you will modernize a traditional two-tier Web service that uses Apache and Postgresql services.

## Setup Apache web server

1. Log into server created in Module 1, LinuxLabVM-CentOS-7-Apache, using putty as root.
2. Run the bash script setupapache.sh

## Setup Postgresql server and import database

1. Log into server created in Module 1, LinuxLabVM-CentOS-7-PostGreSQL, using putty as root.
2. Run the bash script setuppostgresql.sh
3. Log into the postgresql server and run the northwind_postgresql.sql setup file
4. Once the database is created and data uploaded, obtain the ip address of the VM to use in the next step.

## Create the index.php using vi

1. Copy the contents of index.php into a new file on the web server using the same name.
2. Modify the connection string in index.php to match the ip address of the Postgresql server.
