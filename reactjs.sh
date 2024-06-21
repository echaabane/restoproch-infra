#!/bin/bash

# Variables
KEY_PATH="~/.ssh/MyKeyPair.pem"
FRONT_END_IPS=("54.87.53.90" "52.200.135.156")

# Build the React application
npm run build

# Test the React application
npm test

# Deploy the build to the front-end VMs
for ip in "${FRONT_END_IPS[@]}"; do
    scp -i $KEY_PATH -r build/* ec2-user@$ip:/var/www/html
done
