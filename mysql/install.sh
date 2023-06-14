#!/bin/bash

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y debconf-utils zsh htop libaio1
sudo debconf-set-selections <<< "mysql-apt-config mysql-apt-config/select-server select mysql-8.0"
sudo debconf-set-selections <<< "mysql-community-server mysql-community/root-pass password root"
sudo debconf-set-selections <<< "mysql-community-server mysql-community/re-root-pass password root"
wget --user-agent="Mozilla" -O /tmp/mysql-apt-config_0.8.24-1_all.deb https://dev.mysql.com/get/mysql-apt-config_0.8.24-1_all.deb
export DEBIAN_FRONTEND="noninteractive"
sudo -E dpkg -i /tmp/mysql-apt-config_0.8.24-1_all.deb
sudo apt-get update
sudo -E apt-get install mysql-server mysql-client --assume-yes --force-yes
sudo mysql < /home/azureuser/mysql/script/user.sql
sudo mysql < /home/azureuser/mysql/script/schema.sql
sudo mysql < /home/azureuser/mysql/script/data.sql
sudo cp -f /home/azureuser/mysql/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
sudo service mysql restart
sleep 20
