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
curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $logfile
validate $? "Download zip" 
cd /app
unzip -o /tmp/cart.zip &>> $logfile
validate $? "unzip download"
npm install &>> $logfile
validate $? "Download dependencies"
#copy from the obsolute path 
cp /home/centos/robo-shell/cart.service /etc/systemd/system/cart.service
validate $? "copy from obs path"
systemctl daemon-reload &>> $logfile
validate $? "cart DRL"
systemctl enable cart &>> $logfile
validate $? "Enable Cart"
systemctl start cart &>> $logfile
validate $? "Start cart"