#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

timestamp=$(date +%F-%H-%M-%S)
logfile="/tmp/$0-$timestamp.log"
echo "Script started executing at $timestamp" &>> $logfile

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

dnf install nginx -y &>> $logfile
validate $? "Install Nginx"
systemctl enable nginx &>> $logfile
validate $? "Enable Nginx"
systemctl start nginx &>> $logfile
validate $? "Start nginx"
rm -rf /usr/share/nginx/html/* &>> $logfile
validate $? "Remove default"
curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $logfile
validate $? "download web app"
cp /usr/share/nginx/html &>> $logfile
validate $? "moving to nginx html dir"
unzip -o /tmp/web.zip &>> $logfile
validate $? "unzip web"
cp /home/centos/robo-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $logfile
validate $? "copied reverse proxy conf"
systemctl restart nginx &>> $logfile
validate $? "restarted nginx"