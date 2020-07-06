#!/bin/bash
IFS=$'\n'       # make newlines the only separator

#set -x

# OPTS=`getopt -o r: -n 'parse-options' -- "$@"`
# using this negates the later opt parsing.
# Doing modified by newer would be hard, but we can do find where name contains pretty easily.  though
# I will need to decide if it makes sense to implement anything other than contains.


function usage
{
  echo "usage: $0 [--profile aws-profile-name] -name xxxx"
  exit
}

# no opt-parsing..
while true; do
  case "$1" in
    -name )                          arg_name="$2";          shift;;
    -h | --help )                    usage;                  exit;; # quit and show usage
    * ) break ;;            
  esac
  
done

term="$1"
if [[ ! -z $2 ]]; then
  path="$2"
fi



if [[ ! -z $arg_name ]]; then
  parameters=$(aws ssm describe-parameters --parameter-filters "Key=Name,Values=$arg_name,Option=Contains" --query 'Parameters[].[Name]' --output text)

  for param in $parameters; do 
    echo $param

  done

fi








