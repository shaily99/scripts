#!/usr/bin/env bash

# Creates and activates conda environement on compute nodes.
# Installs regularly used packages.
# Won't work on login node because it is not good practice to run anything on login node.

if [[ `hostname` != "babel-login-*.lti.cs.cmu.edu" ]]; then
    conda create -n myenv
    conda activate myenv
    conda install -y pytorch::pytorch torchvision torchaudio -c pytorch
    conda install numpy
    pip install pandas
    pip install argparse
fi