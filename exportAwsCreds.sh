#!/bin/bash
#echo ""
#echo "export TF_VAR_aws_access_key=$1"
#echo "export TF_VAR_aws_secret_key=$2"
#echo "export TF_VAR_aws_session_token=$3"
export TF_VAR_aws_access_key=$AWS_ACCESS_KEY_ID
export TF_VAR_aws_secret_key=$AWS_SECRET_ACCESS_KEY
export TF_VAR_aws_session_token=$AWS_SESSION_TOKEN
