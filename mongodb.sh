#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

timestamp=$(date +%F-%H-%M-%S)
logfile="/tmp/$0-$timestamp.log"

echo -e "The script started executing at $timestamp" &>> $logfile

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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $logfile
validate $? "Copied mongodb repo"
dnf install mongodb-org -y &>> $logfile
validate $? "Copied Mongodb Repo"
systemctl enable mongod
validate $? "Enabled Mongodb"
systemctl start mongod
validate $? "Started Mongodb"
sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf &>> $logfile
validate $? "Editing: Remote access to mongodb"
systemctl restart mongod &>> $logfile
validate $? "Restart Mongodb"
