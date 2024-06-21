#!/bin/bash

# Variables
KEY_NAME="MyKeyPair"
SECURITY_GROUP_FRONT="sg-front"
SECURITY_GROUP_BACK="sg-back"
AMI_ID="ami-0abcdef1234567890"
INSTANCE_TYPE="t2.micro"
REGION="us-east-1"

# Create security groups
aws ec2 create-security-group --group-name $SECURITY_GROUP_FRONT --description "Frontend security group"
aws ec2 create-security-group --group-name $SECURITY_GROUP_BACK --description "Backend security group"

# Launch instances for backend
BACKEND_INSTANCES=($(aws ec2 run-instances --image-id $AMI_ID --count 2 --instance-type $INSTANCE_TYPE --key-name $KEY_NAME --security-groups $SECURITY_GROUP_BACK --query 'Instances[*].InstanceId' --output text --region $REGION))

# Launch instances for frontend
FRONTEND_INSTANCES=($(aws ec2 run-instances --image-id $AMI_ID --count 2 --instance-type $INSTANCE_TYPE --key-name $KEY_NAME --security-groups $SECURITY_GROUP_FRONT --query 'Instances[*].InstanceId' --output text --region $REGION))

# Create Load Balancer for backend
BACK_LB_ARN=$(aws elbv2 create-load-balancer --name back-lb --subnets subnet-12345678 subnet-87654321 --security-groups $SECURITY_GROUP_BACK --query 'LoadBalancers[0].LoadBalancerArn' --output text --region $REGION)

# Create Load Balancer for frontend
FRONT_LB_ARN=$(aws elbv2 create-load-balancer --name front-lb --subnets subnet-12345678 subnet-87654321 --security-groups $SECURITY_GROUP_FRONT --query 'LoadBalancers[0].LoadBalancerArn' --output text --region $REGION)

# Create target groups for backend and frontend
BACK_TG_ARN=$(aws elbv2 create-target-group --name back-tg --protocol HTTP --port 8080 --vpc-id vpc-12345678 --query 'TargetGroups[0].TargetGroupArn' --output text --region $REGION)
FRONT_TG_ARN=$(aws elbv2 create-target-group --name front-tg --protocol HTTP --port 80 --vpc-id vpc-12345678 --query 'TargetGroups[0].TargetGroupArn' --output text --region $REGION)

# Register instances with target groups
for instance in "${BACKEND_INSTANCES[@]}"; do
    aws elbv2 register-targets --target-group-arn $BACK_TG_ARN --targets Id=$instance --region $REGION
done

for instance in "${FRONTEND_INSTANCES[@]}"; do
    aws elbv2 register-targets --target-group-arn $FRONT_TG_ARN --targets Id=$instance --region $REGION
done

# Create listeners for load balancers
aws elbv2 create-listener --load-balancer-arn $BACK_LB_ARN --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=$BACK_TG_ARN --region $REGION
aws elbv2 create-listener --load-balancer-arn $FRONT_LB_ARN --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=$FRONT_TG_ARN --region $REGION
