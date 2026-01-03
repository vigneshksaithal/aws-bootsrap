#!/bin/bash

STACK_NAME=awsbootstrap
REGION=ap-south-1
CLI_PROFILE=awsbootstrap
EC2_INSTANCE_TYPE=t3.micro

# Check if stack exists and is in ROLLBACK_COMPLETE state
STACK_STATUS=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --profile $CLI_PROFILE \
    --region $REGION \
    --query 'Stacks[0].StackStatus' \
    --output text 2>/dev/null)

if [ "$STACK_STATUS" = "ROLLBACK_COMPLETE" ]; then
    echo "Stack is in ROLLBACK_COMPLETE state. Deleting..."
    aws cloudformation delete-stack \
        --stack-name $STACK_NAME \
        --profile $CLI_PROFILE \
        --region $REGION

    echo "Waiting for stack deletion..."
    aws cloudformation wait stack-delete-complete \
        --stack-name $STACK_NAME \
        --profile $CLI_PROFILE \
        --region $REGION

    echo "Stack deleted successfully"
fi

# Deploy the CloudFormation template
echo -e "\n\n======= Deploying main.yml ======="
aws cloudformation deploy \
    --region $REGION \
    --profile $CLI_PROFILE \
    --stack-name $STACK_NAME \
    --template-file main.yml \
    --no-fail-on-empty-changeset \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
      EC2InstanceType=$EC2_INSTANCE_TYPE

# If the deploy succeeded, show the DNS name of the created instance
if [ $? -eq 0 ]; then
  echo -e "\n\n======= Instance Endpoint ======="
  aws cloudformation list-exports \
    --profile $CLI_PROFILE \
    --region $REGION \
    --query "Exports[?Name=='InstanceEndpoint'].Value" \
    --output text
fi
