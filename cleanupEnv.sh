#!/bin/bash

# Clean up exported aws env keys because they are a security risk

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset TF_VAR_aws_access_key
unset TF_VAR_aws_secret_key
unset TF_VAR_aws_session_token

# Common Account
unset TF_VAR_aws_access_key_common
unset TF_VAR_aws_secret_key_common
unset TF_VAR_aws_session_token_common
