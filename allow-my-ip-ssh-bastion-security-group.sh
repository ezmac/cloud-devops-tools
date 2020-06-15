#!/bin/bash
set -eo pipefail

declare ipv6=false
declare cidr=false

function usage
{
    echo "usage: $0 --profile aws-profile-name [--ipv6] ipaddr"
    echo "--ipv6 optional, use if you only have ipv6; has not been tested; sorry" echo "   ";
    echo "  -h | --help              : This message";
}
args=()
# named args
while [ "$1" != "" ]; do
  case "$1" in
    --profile )                   profile="$2";             shift;;
    --use-ipv6 )                  ipv6=true;                     ;; #nothing to consume
    --cidr )                      cidr=true;                     ;; #nothing to consume
    -c )                          cidr=true;                     ;; #nothing to consume
    -h | --help )                 usage;                   exit;; # quit and show usage
    * )                           args+=("$1")             # if no match, add it to the positional args
  esac
  shift # move to next kv pair
done

set -euo pipefail
if [[ -z $profile ]]; then
  usage
  exit
fi
# should only be one positional argument
ipaddr="${args[0]}"
fixed_bits='32'
cidr_term='CidrIp' #options CidrIp or CidrIpv6
ip_class='Ip' # options are Ip or Ipv6
ranges_term="${ip_class}Ranges"

if [[ $ipv6 == true ]]; then
  fixed_bits=64
  cidr_term='CidrIpv6'
  ip_class='Ipv6' # options are Ip or Ipv6
  ranges_term="${ip_class}Ranges"
fi

if [[ $cidr == true ]]; then
  effective_cidr=$ipaddr
else
  effective_cidr="${ipaddr}/${fixed_bits}"
fi

ranges="$ranges_term=[{$cidr_term=$effective_cidr,Description=`hostname`}]"

# ranges="IpRanges=[{CidrIp=$ipaddr/$fixed_bits,Description=`hostname`}]"
current_cidrs=$(
  aws --profile $profile \
  ec2 describe-security-groups \
  --filters Name=group-name,Values=ssh-bastion \
  --query 'SecurityGroups[].IpPermissions[].'$ranges_term'[?Description==`'`hostname`'`][]|[0].'$cidr_term \
  --output text)
revoke_ranges="$ranges_term=[{$cidr_term=$current_cidrs,Description=`hostname`}]"
#revoke_ranges="Ipv6Ranges=[{CidrIpv6=$current_cidrs,Description=`hostname`}]"
sg_id=$(
  aws --profile $profile \
  ec2 describe-security-groups \
  --filters Name=group-name,Values=ssh-bastion \
  --query 'SecurityGroups[].GroupId' \
  --output text)

#aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 22 --cidr $1/$fixed_bits
if [[ "None" != "$current_cidrs" ]]; then
  aws --profile $profile \
    ec2 revoke-security-group-ingress \
    --group-id $sg_id \
    --ip-permissions FromPort=22,ToPort=22,IpProtocol=tcp,$revoke_ranges
fi

aws --profile $profile \
  ec2 authorize-security-group-ingress \
  --group-id $sg_id \
  --ip-permissions FromPort=22,ToPort=22,IpProtocol=tcp,$ranges

echo "Added $effective_cidr to ssh-bastion ($sg_id) security group for aws profile $profile"
