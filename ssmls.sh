#!/bin/bash
IFS=$'\n'       # make newlines the only separator


# OPTS=`getopt -o r: -n 'parse-options' -- "$@"`

# Param filters can be useful in some ssm functions.  but only applies to tag:.+|Name|Type|KeyId|Path|Label|Tier|DataType

function usage
{
    echo "usage: $0 [--profile aws-profile-name] [path]"
    echo "default path is /"
    exit
}
args=()
# named args
debug_mode=false
encryption=false

echo "$1"
while [ "$1" != "" ]; do
  case "$1" in
    --profile )                   profile="$2";             shift;;
    -h | --help )                 usage;                    exit;; # quit and show usage
    * )                           args+=("$1")              # if no match, add it to the positional args
  esac
  shift # move to next kv pair
done

if [[ ${#args[@]} == 0 ]]; then
  path="/"
else
  path=${args[0]}
fi
# could check here for bad opts, but whatever.

if [[ ! -z $path ]]; then
  parameters=$(aws ssm get-parameters-by-path --recursive --path $path --query 'Parameters[].[Name]' --output text)

  for param in $parameters; do
    echo ${param}
  done
fi








