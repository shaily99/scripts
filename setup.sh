#!/usr/bin/env bash

# Creates and activates conda environement on compute nodes.
# Installs regularly used packages.
# Won't work on login node because it is not good practice to run anything on login node.

while getopts ":n" option; do
  case $option in
    n)
      env_name="$OPTARG"
      ;;
    *)
      echo "Usage: $0 [-f file_name] [-d directory_name]"
      exit 1
      ;;
  esac
done

if [[ `hostname` != "babel-login-*.lti.cs.cmu.edu" ]]; then
    conda create -n $env_name
    conda activate $env_name
    conda install pytorch pytorch-cuda=12.1 -c pytorch -c nvidia
    conda install numpy
    conda install pandas
    conda install argparse
fi
