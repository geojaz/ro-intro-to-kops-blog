#!/usr/bin/env bash

export AWS_ACCESS_KEY="PLACEHOLDER"
export AWS_SECRET_KEY="PLACEHOLDER"
export AWS_DEFAULT_REGION="us-east-2"

# Terraform settings
export TF_VAR_aws_access_key="$AWS_ACCESS_KEY"
export TF_VAR_aws_secret_key="$AWS_SECRET_KEY"

# Boto uses slightly different variable names
export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_KEY"

export KOPS_STATE_STORE="s3://eh-kops-dev-state"

# If bucket does not exist:
# aws s3 mb s3://$KOPS_STATE_STORE
# aws s3api put-bucket-versioning --bucket s3://$KOPS_STATE_STORE --versioning-configuration Status=Enabled

