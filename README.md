# awsMFA
Author: Lance Pu (contact@lancepu.dev)

Purpose: Generates a profile authenticated with MFA for AWS CLI

Usuage: 

`bash awsMFA.sh arg1(required) arg2(required)`

Arguments
   
Arg1: Specifies the name of a profile that will contain the accessKey, Secret and Session_Token after MFA authentication
   
Arg2: Specifies the name of the profile used to call the STS service.Contains Access Key for CLI generated in your AWS account

 IMPORTANT REQUIREMENT:
   1. AWS CLI installed (Version 2 Required: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html). You can check for your AWS CLI version by running `aws --version`
   2. Fill out the `MFA_SERIAL`, which is the ARN of your virtual MFA device
