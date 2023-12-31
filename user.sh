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
        exit 1
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

dnf module disable nodejs -y &>> $logfile
validate $? "Disable"
dnf module enable nodejs:18 -y &>> $logfile
validate $? "Enable" 
dnf install nodejs -y &>> $logfile
validate $? "Install"

id roboshop

if [ if $? -ne 0 ]
then 
    useradd roboshop
    validate $? "roboshop user add"
else
    echo -e "roboshop user already exists $Y skipping $N"
fi

mkdir -p /app 
validate $? "Make dir"
curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $logfile
validate $? "Download zip" 
cd /app
unzip -o /tmp/user.zip &>> $logfile
validate $? "unzip download"
npm install &>> $logfile
validate $? "Download dependencies"
cp /home/centos/robo-shell/user.service /etc/systemd/system/user.service
validate $? "copy from obs path"
systemctl daemon-reload &>> $logfile
validate $? "user DRL"
systemctl enable user &>> $logfile
validate $? "Enable User"
systemctl start user &>> $logfile
validate $? "Start User"
cp /home/centos/robo-shell/mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copy mongodb repo"
dnf install mongodb-org-shell -y &>> $logfile
validate $? "Installing mongodb client"
mongo --host mongodb.sridevops.online </app/schema/user.js &>> $logfile
validate $? "Loading user data into mongoDB"
