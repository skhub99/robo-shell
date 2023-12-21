#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
timestamp=$(date +%F-%H-%M-%S)
logfile="/tmp/$0-$timestamp.log"
validate(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2...$R FAILED $N"
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R Error: Please run the script with root user $N"
else
    echo -e "$G You are the root user $N"
fi 
dnf module disable nodejs -y
validate $? "Disable" &>> $logfile
dnf module enable nodejs:18 -y
validate $? "Enable" &>> $logfile
dnf install nodejs -y
validate $? "Install" &>> $logfile
useradd roboshop
validate $? "User Add" &>> $logfile
mkdir /app
validate $? "Make dir" &>> $logfile
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
validate $? "Download zip" &>> $logfile
cd /app
unzip /tmp/catalogue.zip
validate $? "unzip download" &>> $logfile
npm install
validate $? "Download dependencies" &>> $logfile
#copy from the obsolute path 
cp /home/centos/robo-shell/catalogue.service /etc/systemd/system/catalogue.service
validate $? "copy from obs path" &>> $logfile
systemctl daemon-reload
validate $? "catalogue DRL" &>> $logfile
systemctl enable catalogue
validate $? "Enable Cat" &>> $logfile
systemctl start catalogue
validate $? "Start catalogue" &>> $logfile
validate $? "Start" &>> $logfile
cp /home/centos/robo-shell/mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copy mongodb repo" &>> $logfile
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=0
enabled=1
dnf install mongodb-org-shell -y
validate $? "Installing mongodb client" &>> $logfile
mongo --host mongodb.sridevops.online </app/schema/catalogue.js
validate $? "Loading catalogue data into mongoDB" &>> $logfile