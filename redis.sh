#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

timestamp=$(date +%F-%H-%M-%S)
logfile="/tmp/$0-$timestamp.log"
exec &>$logfile
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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
validate $? "Installing remi release"
dnf module enable redis:remi-6.2 -y
validate $? "Enabling redis"
dnf install redis -y
validate $? "Installing Redis"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/redis/redis.conf
validate $? " Allowing remote connections"

systemctl enable redis
validate $? "Enable redis"

systemctl start redis
validate $? "Start redis"
