#!/bin/bash

sudo apt-get update
sudo apt-get install -y openjdk-11-jre unzip
mkdir /home/azureuser/springmvcapp
rm -rf /home/azureuser/springmvcapp/*.*
unzip -o /home/azureuser/springapp/springapp.zip -d /home/azureuser/springmvcapp
sudo mkdir -p /var/log/springapp
sudo cp /home/azureuser/springapp/springapp.service /etc/systemd/system/springapp.service
sudo systemctl start springapp.service
sudo systemctl enable springapp.service
