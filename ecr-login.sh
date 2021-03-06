#!/bin/bash
if [[ ! -z $1 ]]; then
  AWS_ECR_ACCOUNT_ID=$1
fi
if [[ -z $AWS_ECR_ACCOUNT_ID ]]; then
  echo AWS_ECR_ACCOUNT_ID must be set in env or passed as arg 1
  exit -1
fi
if [[ ! -z $AWS_ECR_PROFILE ]]; then
  profile=" --profile $AWS_ECR_PROFILE "
fi
aws $profile sts get-caller-identity >/dev/null
if [[ $? != 0 ]]; then
  echo "ECR requires a valid aws login; either your login is expired or your profile is incorrect"
  echo "This tool uses \$AWS_ECR_PROFILE or \$AWS_PROFILE in that order"
  echo "Values: \$AWS_ECR_PROFILE: \"$AWS_ECR_PROFILE\" | \$AWS_PROFILE: \"$AWS_PROFILE\""
  exit 1
fi

aws $profile ecr get-login --registry-ids $AWS_ECR_ACCOUNT_ID --no-include-email --region us-east-1 | sh
