# IAM-SetDefaultPolicyVersion


-----------------------------------------------------------------
To deploy infra:

make it executable:

chmod +x run_aws_commands.sh

Run to get account id:
 
aws sts get-caller-identity

Replace the account id in the above script:

nano run_aws_commands.sh

Execute the script:
./run_aws_commands.sh 

----------------------------------------------------------------
Destroy infra:

chmod +x delete_infrastructure.sh

aws sts get-caller-identity - copy account id

cd .aws/credentials - copy the access key

nano delete_infrastructure.sh

./delete_infrastructure.sh

----------------------------------------------------------------
