#!/bin/bash

install_dir=${1:-$HOME/.local/bin}

for i in `find . -name \*.sh -not -name install.sh`; do
  bin_name=${i%.sh}
  echo $bin_name
  ln -s $PWD/$i $install_dir/$bin_name
done

