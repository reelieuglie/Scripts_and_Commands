### Install AWS CLI
[ Stolen shamelessly from here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions)
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"  && \
sudo yum install -y unzip || sudo apt-get -y install -y unzip || sudo zypper --non-interactive in unzip  && \
unzip awscliv2.zip && \
sudo ./aws/install
```
### Find ENI by IP address in multiple accounts
```
 for i in $(grep -E "\[*\]" ~/.aws/config | tr "[" " " | tr "]" " " | sed 's/profile//g'); do echo "Account = $i " && for z in $(aws ec2 describe-regions --region us-east-1  --query "Regions[].RegionName[]" --output text); do echo "Region is $z"& aws ec2 describe-network-interfaces --region $z --query 'NetworkInterfaces[*].[{PrivateIP:PrivateIpAddress,InterfaceType:InterfaceType},NetworkInterfaceId,Attachment]' --profile $i --filters Name=private-ip-address,Values=172.31.36.140; done;done  | tee ENI_list.txt
```

### Find Availability of Instance Types Globally (does not check available capacity, just if it's offered in region)
* [Inspiration is here](https://www.youtube.com/watch?v=6U0h8InsW30)
* Replace `p3*` with whatever you are searching for
* [Instance Types](https://instances.vantage.sh/)
```
  instancetype=p3*; for i in $(aws ec2 describe-regions --region us-east-1  --query "Regions[].RegionName[]" --output text); do aws ec2 describe-instance-type-offerings --location-type availability-zone  --filters Name=instance-type,Values=$instancetype--region $i  --output text | awk '{print $3}' | sort -u; done
```
### Check if AMIs are in use within Launch Configurations or Templates in an Account
* This is a bash script. Copy, paste into a file, and then run the file. 
```
#!/bin/bash
# As with all of my scripts, use at your own risk. Checks if AMIs are in use.
# Create Array of AMIs
echo 'Creating an Array of AMIs being used in all Launch Configurations or Templates'
images=()
images=($(for i in $(aws ec2 describe-launch-templates region us-east-2 query 'LaunchTemplates[*].[LaunchTemplateId]' output=text); do aws ec2   describe-launch-template-versions region us-east-2 launch-template-id $i versions $Latest query 'LaunchTemplateVersions[*].[LaunchTemplateData.ImageId]' output=text; done))
images+=($(aws autoscaling describe-launch-configurations region us-east-2 output=text query 'LaunchConfigurations[*].ImageId'))
# Ask for AMI to check
echo Which AMI are we testing for?
read -p "Enter AMI:" ami

# Variable and Array Testing
# echo ${images[@]}
# echo $ami

# Check if array contains the AMI
if " ${images[@]} " = " ${ami} "[[ >> " ${images[@]} "  =  " ${ami} "  ]]; then
echo $ami "is being used in a launch configuration or template"
else
echo $ami "is not being used"
```

### Find source snapshot IDs for EBS Volumes
```
#!/bin/bash
# Finds source snapshot for volumes
# If you just want to run this as a one-off, copy the line below from `aws` to `us-east-1` and paste it into the terminal. 
volumes=$(aws ec2 describe-volumes query "Volumes[*].{VolumeId:VolumeId,SnapshotId:SnapshotId}" output text region us-east-1)
echo $volumes
```
* Similarly, the command below does the same thing, just prettier. 
```
#!/bin/bash

#Searches through us-east-1 for every volume. Echos the volume ID and the snapshots of said volume.
volumes=$(aws ec2 describe-volumes --query "Volumes[*].{VolumeId:VolumeId}" --output text --region us-east-1)
for i in ${volumes[@]};
do echo $i
aws ec2 describe-snapshots --snapshot-id $(aws ec2 describe-volumes --volume-id $i  --query "Volumes[*].{SnapshotId:SnapshotId}" --output text --region us-east-1) --region us-east-1
sleep $[ ( $RANDOM % 4 )  + 1 ]s

# ^ Jitter I guess?
done
```
###  Login to ECR
* Login to ECR from instance in the same region (assuming IAM profile allows it.)
```
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
```
