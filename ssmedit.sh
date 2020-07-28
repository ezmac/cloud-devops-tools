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
  echo "usage: $0 --profile aws-profile-name -f /full/path/to/param [--with-decryption|-d]"
  echo "-f --fullpath: don't prefix anything, use the argument as $param directly.  mutex with e, n, p"
  echo "-d --with-decryption sets parameter as secure string"
  echo "-e --environment unimplemented"
  echo "-n --name unimplemented"
  echo "-p --prefix unimplemented"
  exit
}
args=()
# named args
debug_mode=false
encryption=false

while [ "$1" != "" ]; do
  case "$1" in
    --profile )                   profile="$2";             shift;;
    --full-path )                 fullpath="$2";            shift;; #consume the fullpath
    -f )                          fullpath="$2";            shift;; #consume the fullpath
    --with-decryption )           encryption=true;          ;;      #nothing to consume
    -D )                          debug_mode=true;          ;;      #nothing to consume
    -d )                          encryption=true;          ;;      #nothing to consume
    -f )                          fullpath="$2";            shift;; #consume the fullpath
    -h | --help )                 usage;                    exit;; # quit and show usage
    * )                           args+=("$1")              # if no match, add it to the positional args
  esac
  shift # move to next kv pair
done

function debug {
    if [[ $debug_mode ]]; then
      echo $1
    fi
}


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
  echo "${encryption_arg[@]}"
else
  encryption_arg=("--type" "String" "--overwrite")
fi

set +e
param_content=$(aws --profile $AWS_PROFILE ssm get-parameter --name $fullpath $decryption_arg --query 'Parameter.Value' --output text )
if [[ ! $? ]]; then
  param_content=""
fi
set -e
tempdir=$(mktemp -d "${TMPDIR:-/tmp/}$(basename $0).XXXXXXXXXXXX")
#echo $tempdir
tempfile="${tempdir}/param_content"
#echo $tempfile
echo "${param_content}" > "${tempfile}"
last_mod=`stat -c '%Y' $tempfile`
${EDITOR:-vi} $tempfile

new_contents=$(cat $tempfile)

echo $encryption_arg

new_last_mod=`stat -c '%Y' $tempfile`
if [[ $last_mod != $new_last_mod ]]; then
  if [[ $new_contents != $param_content ]]; then 
    aws --profile $AWS_PROFILE ssm put-parameter --name $fullpath ${encryption_arg[@]} --value file://$tempfile
  else
    echo "no change in content detected; parameter unchanged"
  fi
else
  echo "No change in modified time for temp file; parameter unchanged"
fi


## TODO: Will overrite with same content.  Might want to diff and offer confirmation or something


rm $tempfile
rmdir $tempdir
