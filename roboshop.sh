#!/bin/bash

AMI=ami-03265a0778a880afb
SG_ID=sg-073d40c36b7ddfbf2
instances=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
ZONE_ID=Z05540351JMXZOLZUCWZ7
DOMAIN_NAME=sridevops.online

for i in "${instances[@]}"
do
    echo "Instance is: $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        instance_type="t3.small"
    else
        instance_type="t2.micro"
    fi
    IP_Address=$(aws ec2 run-instances --image-id $AMI --instance-type $instance_type --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "IP Address of $i Instance is: $IP_Address"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Testing creating a record set"
        ,"Changes": [{
        "Action"              : "CREATE"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_Address'"
            }]
        }
        }]
    }
    '
done