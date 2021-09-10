#!/bin/bash
yum -y update
amazon-linux-extras install java-openjdk11
 tee /etc/yum.repos.d/jenkins.repo<<EOF
[jenkins]
name=Jenkins
baseurl=http://pkg.jenkins.io/redhat
gpgcheck=0
EOF
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum -y install jenkins --nobest
systemctl start jenkins
systemctl enable jenkins