#!/bin/bash

set -e
IFS=$'\n'       # make newlines the only separator


## our params are /prefix/app-name/env/filename
## dev perspective, we'd like to be nice.
# options:
#    -f --fullpath: don't prefix anything, use the argument as $param directly.  mutex with e, n, p
#    -e --environment
#    -n --name
#    -p --prefix

# aws ssm get-parameter --name $param --with-decryption --query 'Parameter.Value' --output text )

function usage
{
  echo "usage: $0 --profile aws-profile-name /full/path/to/param"
  exit
}
args=()
# named args
debug_mode=false
encryption=false

while [ "$1" != "" ]; do
  case "$1" in
    --profile )                   profile="$2";             shift;;
    -h | --help )                 usage;                    exit;; # quit and show usage
    * )                           args+=("$1")              # if no match, add it to the positional args
  esac
  shift # move to next kv pair
done

function debug {
    if [[ $debug_mode == true ]]; then
      echo $1
    fi
}

fullpath="${args}"

# TODO: Clean up how we handle profiles
if [[ -z "$profile" ]]; then
  if [[ -z "$AWS_PROFILE" ]]; then
    echo "No profile set"
    exit 1
  else
    profile=$AWS_PROFILE
  fi
fi

set -euo pipefail
if [[ -z $profile ]]; then
  usage
  exit
fi
debug "Using aws profile $profile"
# should only be one positional argument

# Like I want to keep setting it...
export AWS_PROFILE=$profile

decryption_arg="--with-decryption"
if [[ true == $encryption ]]; then 
  encryption_arg=("--type" "SecureString" "--overwrite")
  debug "${encryption_arg[@]}"
else
  encryption_arg=("--type" "String" "--overwrite")
fi

set +e
param_content=$(aws --profile $AWS_PROFILE ssm get-parameter --name $fullpath $decryption_arg --query 'Parameter.Value' --output text )
if [[ ! $? ]]; then
  param_content=""
fi
set -e
echo -n "${param_content}"
