#!/bin/bash

# Function to execute a command and display command output
execute_command() {
    echo "Running: $1"
    eval "$1"
    if [ $? -eq 0 ]; then
        echo "Command succeeded"
    else
        echo "Command failed"
        exit 1
    fi
    echo ""
}

# AWS Account ID
ACCOUNT_ID="XXXXXXXXXXXXX"

# List of commands
commands=(
    "aws iam create-user --user-name devops-engineer"
    "aws iam create-policy --policy-name devops-engineer-policy --policy-document '{\"Version\": \"2012-10-17\",\"Statement\": [{\"Effect\": \"Allow\",\"Action\": [\"codepipeline:ListPipelines\",\"codepipeline:GetPipeline\",\"codepipeline:StartPipelineExecution\",\"codepipeline:StopPipelineExecution\",\"codepipeline:ListPipelineExecutions\",\"codebuild:CreateProject\",\"codebuild:BatchGetBuilds\",\"codebuild:StartBuild\",\"codebuild:StopBuild\",\"codebuild:ListBuilds\",\"codebuild:ListProjects\",\"codebuild:CreateWebhook\"],\"Resource\": \"*\"}]}'"
    "aws iam attach-user-policy --user-name devops-engineer --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/devops-engineer-policy"
    "aws iam create-policy-version --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/devops-engineer-policy --policy-document '{\"Version\": \"2012-10-17\",\"Statement\": [{\"Effect\": \"Allow\",\"Action\": [\"sns:Publish\",\"sns:Subscribe\",\"sns:ListTopics\",\"sns:ListSubscriptions\",\"sns:GetTopicAttributes\",\"sns:GetSubscriptionAttributes\"],\"Resource\": \"*\"}]}' --set-as-default"
    "aws iam create-policy-version --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/devops-engineer-policy --policy-document '{\"Version\": \"2012-10-17\",\"Statement\": [{\"Effect\": \"Allow\",\"Action\": [\"iam:ListAttachedUserPolicies\",\"iam:GetPolicy\",\"iam:GetPolicyVersion\",\"iam:ListPolicyVersions\",\"iam:SetDefaultPolicyVersion\",\"s3:ListBucket\",\"s3:GetObject\"],\"Resource\": \"*\"}]}' --set-as-default"
    "aws iam create-policy-version --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/devops-engineer-policy --policy-document '{\"Version\": \"2012-10-17\",\"Statement\": [{\"Effect\": \"Allow\",\"Action\": [\"sagemaker:CreateNotebookInstance\",\"sagemaker:DeleteNotebookInstance\",\"sagemaker:ListNotebookInstances\",\"sagemaker:StartNotebookInstance\",\"sagemaker:StopNotebookInstance\",\"sagemaker:CreateTrainingJob\",\"sagemaker:DescribeTrainingJob\",\"sagemaker:ListTrainingJobs\",\"sagemaker:CreateModel\",\"sagemaker:DescribeModel\",\"sagemaker:ListModels\",\"sagemaker:CreateEndpointConfig\",\"sagemaker:DescribeEndpointConfig\",\"sagemaker:ListEndpointConfigs\",\"sagemaker:CreateEndpoint\",\"sagemaker:DescribeEndpoint\",\"sagemaker:ListEndpoints\"],\"Resource\": \"*\"}]}' --no-set-as-default"
    "aws iam create-policy-version --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/devops-engineer-policy --policy-document '{\"Version\": \"2012-10-17\",\"Statement\": [{\"Effect\": \"Allow\",\"Action\": \"*\",\"Resource\": \"*\"}]}' --no-set-as-default"
    "aws iam create-access-key --user-name devops-engineer"
)

# Loop through and execute each command
for cmd in "${commands[@]}"; do
    execute_command "$cmd"
done
