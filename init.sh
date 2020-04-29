#!/bin/bash
install_dir=${1:-$HOME/.local/bin}

mkdir -p $install_dir

## TODO: this is a direct copy from the installer.
## Could be put into one location
if [[ $SHELL == `which bash` ]]; then
  shell="bash"
  shellconf="$HOME/.bashrc"
  shellwarn="Bash does weird things with bash_rc and bash profile\n\
    see https://stackoverflow.com/questions/415403/whats-the-difference-between-bashrc-bash-profile-and-environment\n\
    for details\n\
    "
elif [[ $SHELL == `which zsh` ]]; then
  shell="zsh"
  shellconf="$HOME/.zshrc"
  shellwarn=""
fi

grep "$install_dir" $shellconf >/dev/null # we don't care to see the output.
# Capture the exit; grep returns 0 on match, 1 on no match
install_dir_in_shellconf=$?


needs_sourcing=false

if [ $install_dir_in_shellconf != 0 ]; then
  echo "export PATH=$install_dir:\$PATH">>$shellconf
  echo "Added $install_dir to path in $shellconf"
  needs_sourcing=true
fi

if [ ! -f ~/.environmental_variables ]; then
  cp ./environmental_variables.dist ~/.environmental_variables
  echo "Copied default environmental_variables file to ~/.environmental_variables"
  echo "TODO: edit this hidden file to set variables the tools will use"
fi

grep "environmental_variables" $shellconf >/dev/null # we don't care to see the output.
# Capture the exit; grep returns 0 on match, 1 on no match
env_vars_in_shellconf=$?

if [ $env_vars_in_shellconf != 0 ]; then
  echo "source ~/.environmental_variables">>$shellconf
  echo "Added \"source ~/.environmental_variables\" to $shellconf"
  needs_sourcing=true
fi

if [[ true == $needs_sourcing ]]; then
  echo "TODO: run the following command:"
  echo "source $shellconf"
fi
