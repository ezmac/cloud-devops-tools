#!/bin/bash

install_dir=${1:-$HOME/.local/bin}

if [ ! -d $install_dir ]; then
  echo "$install_dir did not exist, please check that it does or set your own."
  exit 1
fi

echo "$PATH"|grep $install_dir >/dev/null # we don't care to see the output.
# Capture the exit; grep returns 0 on match, 1 on no match
install_dir_in_path=$?

if [ $install_dir_in_path != 0 ]; then
  echo "install_dir not in path.  This will mean tools are not usable without setting full path"
  exit 1
fi

# Effort to make more flexible on zsh/bash
shell="unknown"
shellconf="unknown"
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
# We're not gonna handle korn

grep "$install_dir" $shellconf >/dev/null # we don't care to see the output.
# Capture the exit; grep returns 0 on match, 1 on no match
install_dir_in_shellconf=$?

if [ $install_dir_in_shellconf != 0 ]; then
  echo "install_dir not in shellconf. This can lead to confusion and tools not being found."
  echo "You want to verify that 'export PATH=$install_dir:\$PATH' is in your $shellconf (without surrounding single quotes)"
fi

grep "environmental_variables" $shellconf >/dev/null # we don't care to see the output.
# Capture the exit; grep returns 0 on match, 1 on no match
env_vars_in_shellconf=$?

if [ $env_vars_in_shellconf != 0 ]; then
  echo "no environmental_variables file found in $shellconf.  Some tools may not work correctly"
  echo "please add 'source ~/.environmental_variables' to your $shellconf (without surrounding single quotes)"
fi

echo "Tools installed:"

for i in `find . -name \*.sh -not -name install.sh -not -name init.sh`; do
  bin_name=${i%.sh}
  echo " $bin_name"
  ln -fs $PWD/$i $install_dir/$bin_name
done

