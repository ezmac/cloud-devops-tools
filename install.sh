#!/bin/bash

install_dir=${1:-$HOME/.local/bin}

if [ ! -d $install_dir ]; then
  echo "$install_dir did not exist, please check that it does or set your own."
  exit 1
fi

for i in `find . -name \*.sh -not -name install.sh`; do
  bin_name=${i%.sh}
  echo $bin_name
  ln -fs $PWD/$i $install_dir/$bin_name
done

