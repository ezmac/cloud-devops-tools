#!/bin/bash
IFS=$'\n'       # make newlines the only separator

#set -x

OPTS=`getopt -o r: --long recursive -n 'parse-options' -- "$@"`


# really I need to clean up opt parsing
while true; do
  case "$1" in
    -r | --recursive) 
             recursive=true; shift;;
    * ) break ;;            
  esac
  
done
term="$1"
if [[ ! -z $2 ]]; then
  path="$2"
fi



# So, basically, ssmgrep 'close enough expression to grep'

# step 1, describe parameters
  #may be relegated later to an if condition

  # if no path, grab all parameters in form of 
  # name          value
  # cut manages to split them correctly so that we get the content and the name.
  # we 
if [[ ! -z $path ]]; then
  parameters=$(aws ssm get-parameters-by-path --recursive --path $path --query 'Parameters[].[Name,Value]' --with-decryption --output text)

  for param in $parameters; do 
    param_content=$(echo "$param"|cut -f2 -d\ )
    grep_results=$(echo "$param_content" | grep --color=always $term 1>/dev/null)
    if [[ 0 == $? ]]; then 
      echo $(echo \"$param\"|cut -f1 -d\ ) $grep_results
    fi
  done
else
  parameters=$(aws ssm describe-parameters --query 'Parameters[].[Name]' --output text)
  for param in $parameters; do 
    param_content=$(aws ssm get-parameter --name $param --with-decryption --query 'Parameter.Value' --output text )
    grep_results=$(echo "$param_content" | grep --color=always $term )
    if [[ 0 == $? ]]; then 
      echo "$param $grep_results"
    fi
  done
fi








