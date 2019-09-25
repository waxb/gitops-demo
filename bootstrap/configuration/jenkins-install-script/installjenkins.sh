#!/bin/bash
#note: this is just a copy-pasta from https://linuxize.com/post/how-to-install-jenkins-on-centos-7

sudo yum install java-1.8.0-openjdk-devel -y
curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo
sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
sudo yum install jenkins -y
sudo systemctl start jenkins
systemctl status jenkins && sudo systemctl enable jenkins

sudo yum install ansible -y
wget https://releases.hashicorp.com/terraform/0.12.9/terraform_0.12.9_linux_amd64.zip
sudo unzip ./terraform_0.12.9_linux_amd64.zip -d /usr/local/bin/

openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365
