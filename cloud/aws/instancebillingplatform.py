#!/usr/bin/env python
# This runs `describeInstances` in all regions, and `describeImages` on all AMIs that are associated with a currently existing instance. 
# Then it parses `DescribeInstances` for Instance ID and AMI ID, and `DescribeImages` for Platform Details.
# It will then prin them like this:
# i-1234 ami-1234 Linux/UNIX
#
#
# Note: This assumes AWS Credentials are set with ENV Variables. 
#
# References:
# Initial code yoinked from: https://medium.com/@shimo164/detect-running-ec2-instances-in-all-regions-with-boto3-2f403adf4ea2
# Describe Instances: https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/describe_instances.html
# Describe Images: https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/describe_images.html
# Describe Regions: https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/describe_regions.html
# AMI Platform Details: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/billing-info-fields.html



import boto3 
from botocore.config import Config
# Find all regions
def available_regions(service):
    regions = []
    client = boto3.client(service)
    response = client.describe_regions()

    for item in response["Regions"]:
        regions.append(item["RegionName"])

    return regions

# Return Platform Details of an AMI
def platformdetails(imageid):
        imagecheck = boto3.client("ec2", config=my_config)
        response = imagecheck.describe_images(ImageIds=[imageid])
        platform = response["Images"][0]["PlatformDetails"]
        return platform

# Find instances, grab AMI and Platform Details. Return them to STDOUT
def checkInstance():
        client = boto3.client("ec2", config=my_config)
        response = client.describe_instances()
        for r in response["Reservations"]:
            instance_id = r["Instances"][0]["InstanceId"]
            imageID = r["Instances"][0]["ImageId"]
            Platform = platformdetails(imageID)
            print(str(instance_id) +" "+ str(imageID) +" "+ str(Platform))

# Main Chunk of code (put in a 'main' function?)

regions = available_regions("ec2")
for region in regions:
# Change regions with config
    my_config = Config(region_name=region)
    checkInstance()
