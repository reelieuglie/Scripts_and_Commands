#!/bin/bash
####
# Starter template that has variables for:
# AWS CLI command path, Region and Profile
# Also has a loop to gather variables provided to the command
#####

######
# Setup CLI Variables
######
cmd="aws"

#####
# Collect Region and Profile Variables
####
while (( $# > 0 )); do
        case $1 in
                -r|--region) region="$2"; shift;;
                -p|--profile) profile="$2"; shift;;
                -h|--help) echo "Use -r for region and -p for profile";
                        return 1;;
                \?) echo "Unknown Option";
                        return 2;;
                *) break;;
        esac
        shift
done

if [ ! -z "$profile" ]; then
	cmd="$cmd --profile $profile"
fi

if [ ! -z "$region" ]; then
	cmd="$cmd --region $region"
fi



