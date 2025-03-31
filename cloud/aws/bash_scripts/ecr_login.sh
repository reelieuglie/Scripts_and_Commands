#!/bin/bash
####
# Automatically login to ECR, because I get tired of changing the account number and region manually. 
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html#cli-authenticate-registry
#####
#Check if aws cli exists
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions
if  ! command -v aws;
then
	echo " AWS CLI Not Installed"
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"  && \
	sudo yum install -y unzip || sudo apt-get -y install -y unzip || sudo zypper --non-interactive in unzip  && \
	unzip awscliv2.zip && \
	sudo ./aws/install
fi
# Check if IMDS is being used.
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-metadata-v2-how-it-works.html
# 
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
if [ -z $TOKEN ];
then
	echo "IMDS does not seem to be present. Please provide region and account ID at prompts"
	echo " What Region are you logging into ECR in?"
	read region
	echo "What is your account number?"
	read account
else
	account=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep accountId | cut -d "\"" -f 4)
	region=$( curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/region)
fi
# Actually Login to ECR
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html#cli-authenticate-registry
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $account.dkr.ecr.$region.amazonaws.com
