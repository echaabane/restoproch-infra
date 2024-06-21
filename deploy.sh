#!/bin/bash

# Variables
KEY_PATH="~/.ssh/MyKeyPair.pem"
FRONT_END_IPS=("34.228.54.111" "184.73.99.177")
PROJECT_DIR="hello-world"

# Change to the project directory
cd $PROJECT_DIR

# Install dependencies
npm install

# Build the React application
npm run build

# Test the React application
npm test

# Deploy the build to the front-end VMs
for ip in "${FRONT_END_IPS[@]}"; do
    scp -i $KEY_PATH -r build/* ec2-user@$ip:/var/www/html
done
