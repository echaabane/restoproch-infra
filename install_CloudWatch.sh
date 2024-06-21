#!/bin/bash

# Variables
FRONT_END_IPS=("front-end-vm-ip-1" "front-end-vm-ip-2")
BACK_END_IPS=("3.80.139.79" "3.80.98.252")
KEY_PATH="~/.ssh/MyKeyPair.pem"

# Command to install CloudWatch agent
INSTALL_CW_AGENT="sudo yum install -y amazon-cloudwatch-agent"

# Command to configure CloudWatch agent
CONFIGURE_CW_AGENT="sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard"

# Command to start CloudWatch agent
START_CW_AGENT="sudo systemctl start amazon-cloudwatch-agent"

# Loop through all instances and install, configure, and start CloudWatch agent
for ip in "${FRONT_END_IPS[@]}" "${BACK_END_IPS[@]}"; do
    ssh -i $KEY_PATH ec2-user@$ip $INSTALL_CW_AGENT
    ssh -i $KEY_PATH ec2-user@$ip $CONFIGURE_CW_AGENT
    ssh -i $KEY_PATH ec2-user@$ip $START_CW_AGENT
done
