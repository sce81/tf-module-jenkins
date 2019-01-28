#!/bin/bash

mkdir /ebs
sudo mount /dev/nvme1n1 /ebs
mkdir -p /ebs/jenkins
sudo ln -s /ebs/jenkins /var/lib/

wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get -y update
sudo apt-get -y install openjdk-8-jre openjdk-8-jdk


sudo apt-get -y install jenkins

sudo service jenkins start