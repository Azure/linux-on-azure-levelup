# Module 2 - Apache and Postgresql server modernization

Overview

In this workshop you will build a traditional two-tier Web service that uses Apache and Postgresql services which can be modernized using PaaS.

**NOTE** Ensure that you have updated the VM's using yum before running the following steps.

## Setup Postgresql server and import database

1. Log into server created in Module 1, LinuxLabVM-CentOS-7-PostgreSQL, using putty as root. Type in the command to set the hostname of the server. Then reboot the server.

```bash
hostnamectl set-hostname postgresql
```

```bash
reboot
```

**NOTE** Changing the host name will make it easier to identify if you open several SSH connections with Putty.

1. Log into the postgresql server using putty as the root user. Download the postgresql setup script using curl

```bash
curl -o /root/setuppostgresql.sh https://raw.githubusercontent.com/Azure/linux-on-azure-levelup/main/Module%202%20-%20Modernize/setuppostgresql.sh
```
2. Now run the script to install postgresql server

```bash
bash setuppostgresql.sh
```

3. Log into the postgresql server

```bash
sudo -u postgres psql
```
4. Run the SQL script to create the sample database

```bash
\i /northwind_postgresql.sql;
```
5. Connect to the database

```bash
\c northwind;
```

6. Verify that the database was created

```bash
\dt
```

## Setup Apache web server

1. Log into server created in Module 1, LinuxLabVM-CentOS-7-Apache, using putty as root. Type in the command to set the hostname of the server. Then reboot the server.

```bash
hostnamectl set-hostname apache
```

```bash
reboot
```

**NOTE** Changing the host name will make it easier to identify if you open several SSH connections with Putty.

1. Log into the server using putty as the root user. Download the apache setup script using curl

```bash
curl -o /root/setupapache.sh https://raw.githubusercontent.com/Azure/linux-on-azure-levelup/main/Module%202%20-%20Modernize/setupapache.sh
```

2. Now run the script to install apache web server

```bash
bash setupapache.sh
```
3. Now download the sample php file into the web directory

```bash
curl -o /var/www/html/index.php https://raw.githubusercontent.com/Azure/linux-on-azure-levelup/main/Module%202%20-%20Modernize/index.php
```
4. The sample php file has a postgresql database connection string that needs to be modified. Using vi as an editor open the file and change the IP Address to the PostgreSQL Server

```bash
vi /var/www/html/index.php
```
