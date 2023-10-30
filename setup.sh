#!/usr/bin/env bash

# Creates and activates conda environement on compute nodes.
# Installs regularly used packages.
# Won't work on login node because it is not good practice to run anything on login node.

if [[ `hostname` != "babel-login-*.lti.cs.cmu.edu" ]]; then
    conda create -n myenv
    conda activate myenv
    conda install pytorch pytorch-cuda=12.1 -c pytorch -c nvidia
    conda install numpy
    conda install pandas
    conda install argparse
fi
