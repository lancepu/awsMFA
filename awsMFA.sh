#! /bin/bash
############################################################################
# Script Name: awsMFA
# Author: Lance Pu (contact@lancepu.dev)
# Purpose: Generates a profile authenticated with MFA for AWS CLI
# Usuage: bash awsMFA.sh arg1(required) arg2(required) 
#         OR
#         chmod +x awsMFA.sh
#         ./awsMFA.sh
# Arguments
#   Arg1: Specifies the name of a profile that will contain the accessKey,
#         Secret and Session_Token after MFA authentication
#   Arg2: Specifies the name of the profile used to call the STS service.
#         Contains Access Key for CLI generated in your AWS account
#
# IMPORTANT REQUIREMENT:
#   1. AWS CLI installed
#   2. Fill out the MFA_SERIAL, which is the ARN of your virtual MFA device
#
############################################################################

# Get profiles names from arguments
MFA_PROFILE_NAME=$1
BASE_PROFILE_NAME=$2

[ -z "$1" ] && echo "A MFA Profile name is required" && exit 1
[ -z "$2" ] && echo "A Base Profile name is required" && exit 1

# Set default region
DEFAULT_REGION="REGION"

# Set default output
# DEFAULT_OUTPUT="json"

# MFA Serial (ARN)
MFA_SERIAL="MFA_SERIAL"

# Generate Security Token Flag
GENERATE_ST="true"

# Checking profile for expiration time: default 12 hours
MFA_PROFILE_EXISTS=`more ~/.aws/credentials | grep $MFA_PROFILE_NAME | wc -l`
if [ $MFA_PROFILE_EXISTS -eq 1 ]; then
    EXPIRATION_TIME=$(aws configure get expiration --profile $MFA_PROFILE_NAME)
    NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    if [[ "$EXPIRATION_TIME" > "$NOW" ]]; then
        echo "The Session Token is still valid, new Token is not required."
        GENERATE_ST="false"
    fi
fi

if [ "$GENERATE_ST" = "true" ]; then
    read -p "Token code for MFA Device ($MFA_SERIAL): " TOKEN_CODE
    echo "Generating new IAM STS Token ..."
    read -r AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN EXPIRATION < <(aws sts get-session-token --profile $BASE_PROFILE_NAME --output text --query 'Credentials.*' --serial-number $MFA_SERIAL --token-code $TOKEN_CODE)
    if [ $? -ne 0 ]; then
        echo "An error occured. AWS credentials file not updated."
    else
        aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile $MFA_PROFILE_NAME
        aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile $MFA_PROFILE_NAME
        aws configure set aws_session_token "$AWS_SESSION_TOKEN" --profile $MFA_PROFILE_NAME
        aws configure set expiration "$EXPIRATION" --profile $MFA_PROFILE_NAME
        aws configure set region "$DEFAULT_REGION" --profile $MFA_PROFILE_NAME
        echo "Successfully generated STS Session Token and updated AWS credentials file"
    fi
fi     
