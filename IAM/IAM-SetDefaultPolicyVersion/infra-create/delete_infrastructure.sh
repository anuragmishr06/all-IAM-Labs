#!/bin/bash

# Function to execute a command and display command output
execute_command() {
    echo "Running: $1"
    eval "$1"
    if [ $? -eq 0 ]; then
        echo "Command succeeded"
    else
        echo "Command failed"
    fi
    echo ""
}

# AWS Account ID and Access Key ID
ACCOUNT_ID="XXXXXXXXXXXXXXX"
ACCESS_KEY_ID="XXXXXXXXXXXXXX"

# List of commands to delete infrastructure
delete_commands=(
    "aws iam delete-policy-version --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/devops-engineer-policy --version-id v4"
    "aws iam delete-policy-version --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/devops-engineer-policy --version-id v3"
    "aws iam delete-policy-version --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/devops-engineer-policy --version-id v2"
    "aws iam delete-policy-version --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/devops-engineer-policy --version-id v1"
    "aws iam detach-user-policy --user-name devops-engineer --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/devops-engineer-policy"
    "aws iam delete-policy --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/devops-engineer-policy"
    "aws iam delete-access-key --user-name devops-engineer --access-key-id ${ACCESS_KEY_ID}"
    "aws iam delete-user --user-name devops-engineer"
)

# Loop through and execute each delete command
for delete_cmd in "${delete_commands[@]}"; do
    execute_command "$delete_cmd"
done
