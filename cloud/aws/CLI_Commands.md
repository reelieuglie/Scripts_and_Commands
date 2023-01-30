### Install AWS CLI
[[ Stolen shamelessly from here]](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions)
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
* [[Inspiration is here]](https://www.youtube.com/watch?v=6U0h8InsW30)
* Replace `p3*` with whatever you are searching for
* [[Instance Types]](https://instances.vantage.sh/)
```
  instancetype=p3*; for i in $(aws ec2 describe-regions --region us-east-1  --query "Regions[].RegionName[]" --output text); do aws ec2 describe-instance-type-offerings --location-type availability-zone  --filters Name=instance-type,Values=$instancetype--region $i  --output text | awk '{print $3}' | sort -u; done
```
### Check if AMIs are in use within Launch Configurations or Templates in an Account
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
