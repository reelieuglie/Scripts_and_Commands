#!/bin/bash
# This takes a few minutes to run, especially in larger regions. It is not designed for speed. 
# Start it, make sure it's responding with messages like `m4.xlarge xen` and then grab a coffee, come back in 5. 


# Provide variables
regvar=""
profvar=""
while (( $# > 0 )) ; do
	case $1 in 
		-r|--region) regvar="--region $2"; shift;;
		-p|--profile) profvar="--profile $2";shift ;;
		-h|--help) echo "Use -r for Region, and -p for profile";
			return 1;;
		\?) echo "Unknown Option";
	        		return 2;;
	        *) break;;
       esac
       shift
done

# Check if AWSCLI is installed and in path
if ! command -v aws > /dev/null; then
	echo "The command aws is not in the \$PATH or not installed. Please fix. Exiting."
	exit 1
fi
#
# Variable for AWS Command including profile and region
cmd="aws $profvar $regvar"

###
## Get Instance Types
###

#Declare Array
declare -a instancetypes

#Populate Array
instancetypes=($($cmd ec2 describe-instance-type-offerings --location-type region --no-cli-pager  --query "InstanceTypeOfferings[*].InstanceType" --output text --no-cli-pager))

#Function to create list of instances
#Sleep is to avoid throttling
instancelist() {
for i in "${instancetypes[@]}"
do 
 $cmd ec2 describe-instance-types --instance-types "$i"    --no-cli-pager --query 'InstanceTypes[*].[InstanceType,Hypervisor]' --output text --no-cli-pager
 sleep .5
done 
}

# Pipe to grep for xen
instancelist | grep -i "xen
