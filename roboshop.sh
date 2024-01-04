#!/bin/bash

AMI=ami-03265a0778a880afb
SG_ID=sg-073d40c36b7ddfbf2
instances=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")

for i in "${instances[@]}"
do
    echo "instance is: $i"
    if [ $i == "mongodb" ] || if [ $i == "mysql" ] || if [ $i == "shipping" ]
    then
        instance_type="t3.small"
    else
        instance_type="t2.micro"
    fi
    aws ec2 run-instances --image-id $AMI --instance-type $instance_type --security-group-ids $SG_ID
done