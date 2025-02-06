#!/bin/bash

echo "What's going to be the mame for the Venv?:"
read _VenvName
mkdir -p VirtualEnvs 
virtualenv -p /usr/bin/python3 ~/VirtualEnvs/$_VenvName
source ~/VirtualEnvs/$_VenvName/bin/activate
pip install --upgrade pip
pip install numpy matplotlib notebook
python -m notebook

