#!/bin/bash

set -e
IFS=$'\n'       # make newlines the only separator


# Having tee available would be useful.  Then we could cat into a param.

function usage
{
  echo "usage: $0 --profile aws-profile-name /full/path/to/param"
  echo "TODO:..  sorry.  use it like tee"
  exit
}
args=()
# named args
debug_mode=false
append=false
secure_string=true
encryption=false

while [ "$1" != "" ]; do
  case "$1" in
    --profile )                   profile="$2";             shift;;
    -a )                          append=true;          ;;      #nothing to consume
    -D )                          debug_mode=true;          ;;      #nothing to consume
    --type )                      parameter_type="$2";          ;;      #nothing to consume
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

# Read from stdin
stdin_content=`less <&0`

set +e
param_content=$(aws --profile $AWS_PROFILE ssm get-parameter --name $fullpath $decryption_arg --query 'Parameter.Value' --output text )
if [[ ! $? ]]; then
  param_content=""
fi
set -e
# tempdir=$(mktemp -d "${TMPDIR:-/tmp/}$(basename $0).XXXXXXXXXXXX")
#echo $tempdir
# tempfile="${tempdir}/param_content"
#echo $tempfile
# echo "${param_content}" > "${tempfile}"
# last_mod=`stat -c '%Y' $tempfile`
# ${EDITOR:-vi} $tempfile

# new_contents=$(cat $tempfile)

debug $append
debug $encryption_arg

debug $stdin_content
debug $param_content
if [[ false == $append ]]; then
  if [[ "$param_content" != "$stdin_content" ]]; then 
    aws --profile $AWS_PROFILE ssm put-parameter --name $fullpath ${encryption_arg[@]} --value "$stdin_content"
  else
    echo "no change in content detected; parameter unchanged"
  fi
else
    aws --profile $AWS_PROFILE ssm put-parameter --name $fullpath ${encryption_arg[@]} --value "$param_content$stdin_content"
fi


